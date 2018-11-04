import Foundation
import ReactiveSwift
import ReactiveTask
import Result

/// Model that represents a device returned by simctl.
public struct Device: Decodable, Equatable {
    /// A string that summarizes the device availability.
    /// Example: (unavailable, runtime profile not found)
    public let availability: String

    /// True if the device is available.
    public let isAvailable: Bool?

    /// A string that represents the state of the device.
    /// Example: Shutdown
    public let state: String

    /// The name of the device.
    /// Example: Apple TV 4K
    public let name: String

    /// Device unique identifier.
    /// Example: B9AC1102-025F-4921-B39D-45E18D484FC4
    public let udid: String

    /// When the device is not available, this string contains
    /// a description of why the device is not available.
    /// If the device is available, this string is empty.
    public let availabilityError: String?

    /// Name of the device runtime.
    /// Example: iOS 12.1
    public let runtimeName: String

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case availability
        case state
        case isAvailable
        case name
        case udid
        case availabilityError
        case runtimeName
    }

    /// Initializes the device with its attributes.
    ///
    /// - Parameters:
    ///   - availability: A string that summarizes the device availability.
    ///   - state: A string that represents the state of the device.
    ///   - isAvailable: True if the device is available.
    ///   - name: The name of the device.
    ///   - udid: Device unique identifier.
    ///   - availabilityError: A description of why the device is not available.
    ///   - runtimeName: Name of the device runtime.
    init(availability: String,
         state: String,
         isAvailable: Bool?,
         name: String,
         udid: String,
         availabilityError: String?,
         runtimeName: String) {
        self.availability = availability
        self.isAvailable = isAvailable
        self.state = state
        self.name = name
        self.udid = udid
        self.availabilityError = availabilityError
        self.runtimeName = runtimeName
    }

    // MARK: - Public

    /// Gets the list of devices from the system.
    ///
    /// - Returns: List of devices.
    /// - Throws: An error if the simctl command fails.
    public static func list() throws -> [Device] {
        guard let devices = try Reactive.list().single()?.dematerialize() else {
            throw SimulatorError.noOutput
        }
        return devices
    }

    /// Returns the type of device reading the value from the device plist file.
    ///
    /// - Returns: Device type.
    /// - Throws: Throws a DeviceError.deviceTypeNotFound if the device plist can't be read, the deviceType attribute is missing or it has the wrong type.
    public func deviceType() throws -> String {
        guard let deviceType = try plist()["deviceType"] as? String else {
            throw SimulatorError.deviceTypeNotFound
        }
        return deviceType
    }

    /// Returns the device runtime identifier.
    ///
    /// - Returns: Device runtime identifier.
    /// - Throws: An error if the device plist cannot be opened or the runtime identifier is missing.
    public func runtimeIdentifier() throws -> String {
        guard let deviceType = try plist()["runtime"] as? String else {
            throw SimulatorError.runtimeNotFound
        }
        return deviceType
    }

    /// Returns the device global preferences.
    ///
    /// - Returns: Device global preferences.
    /// - Throws: If the file cannot be read or has an invalid format.
    public func globalPreferences() throws -> [String: Any] {
        let data = try Data(contentsOf: globalPreferencesPlistPath())
        return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
    }

    /// Returns the  device device.plist content.
    ///
    /// - Returns: Device.plist content.
    /// - Throws: An error if the file cannot be read or has an invalid format.
    public func plist() throws -> [String: Any] {
        let data = try Data(contentsOf: devicePlistPath())
        let plist = try PropertyListSerialization.propertyList(from: data,
                                                               options: [],
                                                               format: nil) as! [String: Any]
        return plist
    }

    /// Returns the device runtime.
    ///
    /// - Returns: Device runtime.
    /// - Throws: A SimulatorError if the runtime cannot be obtained.
    public func runtime() throws -> Runtime {
        let runtimeIdentifier = try self.runtimeIdentifier()
        guard let runtime = try Runtime.list().first(where: { $0.identifier == runtimeIdentifier }) else {
            throw SimulatorError.runtimeNotFound
        }
        return runtime
    }

    /// Return the path to the global preferences plist fine.
    ///
    /// - Returns: Path to the global preferences plist file.
    public func globalPreferencesPlistPath() -> URL {
        return homePath().appendingPathComponent("data/Library/Preferences/.GlobalPreferences.plist")
    }

    /// Returns the path to the device device.plist file.
    ///
    /// - Returns: Path to the device.plist file.
    public func devicePlistPath() -> URL {
        return homePath().appendingPathComponent("device.plist")
    }

    /// Returns the device home directory.
    ///
    /// - Returns: Path to the device home directory.
    public func homePath() -> URL {
        return Device.devicesPath().appendingPathComponent(udid)
    }

    /// Returns the runtime path.
    ///
    /// - Returns: Runtime path.
    /// - Throws: An error if the path cannot be obtained.
    public func runtimePath() throws -> URL {
        return try runtimePath(xcode: Xcode())
    }

    /// Returns the path to the runtime launchctl binary.
    ///
    /// - Returns: Path to the launchctl binary.
    /// - Throws: An error if it can't be found.
    public func launchCtlPath() throws -> URL {
        return try runtimePath().appendingPathComponent("bin/launchctl")
    }

    public func services() throws -> [Service] {
        return try services(shell: Shell.shared)
    }

    func services(shell: Shelling) throws -> [Service] {
        guard let data = try shell.run(launchPath: try self.launchCtlPath().path, arguments: ["list"])
            .ignoreTaskData()
            .single()?.dematerialize() else {
            return []
        }
        guard let output = String(data: data, encoding: .utf8) else {
            throw ShellError.nonUtf8Output
        }
        return try output.split(separator: "\n")
            .dropFirst()
            .compactMap({ (line) -> Service? in
                let components = line.split(separator: "\t")
                if components.count != 3 { throw SimulatorError.invalidLaunchCtlListOutput }
                let pid = String(components[0])
                let status = Int(components[1])!
                let label = String(components[2])
                return Service(pid: pid, status: status, label: label)
            })
    }

    /// Returns the runtime path.
    ///
    /// - Parameter xcode: Xcode instance to read Xcode variables.
    /// - Returns: Runtime path.
    /// - Throws: An error if the path cannot be obtained.
    func runtimePath(xcode: Xcoding) throws -> URL {
        let fileManager = FileManager.default
        let runtimeIdentifier = try self.runtimeIdentifier()

        // We check the runtimes in the Xcode profiles directory and the developer CoreSimulator folder
        var pathsToCheck: [URL] = []
        if let path = try xcode.runtimeProfilesPath(platform: self.runtime().platform).single()?.dematerialize() {
            pathsToCheck.append(path)
        }
        pathsToCheck.append(URL(fileURLWithPath: "/Library/Developer/CoreSimulator/Profiles/Runtimes/"))
        let paths = try pathsToCheck.flatMap { try fileManager.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil, options: []) }

        // We check that the the runtime bundle identifier matches the device runtime id.
        for path in paths {
            let plistPath = path.appendingPathComponent("Contents/Info.plist")
            if !fileManager.fileExists(atPath: plistPath.path) {
                continue
            }
            let plistData = try Data(contentsOf: plistPath)
            guard let plist = try PropertyListSerialization.propertyList(from: plistData,
                                                                         options: [],
                                                                         format: nil) as? [String: Any],
                let bundleIdentifier = plist["CFBundleIdentifier"] as? String else {
                continue
            }
            if bundleIdentifier != runtimeIdentifier {
                continue
            }
            let rootPath = path.appendingPathComponent("Contents/Resources/RuntimeRoot")
            if fileManager.fileExists(atPath: rootPath.path) {
                return rootPath
            }
        }
        throw SimulatorError.runtimeProfileNotFound
    }

    /// It returns the system directory where all the devices are stored.
    ///
    /// - Returns: Path to the directory that contains all the devices.
    static func devicesPath() -> URL {
        let homeDirectory = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        return homeDirectory.appendingPathComponent("Library/Developer/CoreSimulator/Devices")
    }

    // MARK: - Equatable

    /// Compares two devices returning true if both devices are the same.
    ///
    /// - Parameters:
    ///   - lhs: First device to be compared.
    ///   - rhs: Seconde device to be compared.
    /// - Returns: True if both devices are the same.
    public static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.availability == rhs.availability &&
            lhs.state == rhs.state &&
            lhs.isAvailable == rhs.isAvailable &&
            lhs.name == rhs.name &&
            lhs.udid == rhs.udid &&
            lhs.availabilityError == rhs.availabilityError &&
            lhs.runtimeName == rhs.runtimeName
    }

    // MARK: - Reactive

    public struct Reactive {
        /// Returns a signal producer that gets the list of devices from the system.
        ///
        /// - Returns: A signal producer that returns the devices.
        public static func list() -> SignalProducer<[Device], SimulatorError> {
            return list(shell: Shell.shared)
        }

        /// Returns a signal producer that gets the list of devices from the system.
        ///
        /// - Parameter shell: Shell instance to run the simctl commands.
        /// - Returns: A signal producer that returns the devices.
        static func list(shell: Shelling) -> SignalProducer<[Device], SimulatorError> {
            let decoder = JSONDecoder()
            return shell.simctl(["list", "-j", "devices"])
                .ignoreTaskData()
                .mapError({ SimulatorError.shell($0) })
                .attemptMap({ (data) -> Result<Any, SimulatorError> in
                    do {
                        return try Result.success(JSONSerialization.jsonObject(with: data, options: []))
                    } catch {
                        return Result.failure(SimulatorError.jsonSerialize(error))
                    }
                })
                .attemptMap({ (object) -> Result<[String: [[String: Any]]], SimulatorError> in
                    guard let dictionary = object as? [String: Any],
                        let runtimes = dictionary["devices"] as? [String: [[String: Any]]] else {
                        return Result.failure(SimulatorError.invalidFormat)
                    }
                    return Result.success(runtimes)
                })
                .attemptMap { (runtimes) -> Result<[Device], SimulatorError> in
                    do {
                        let devices = try runtimes.reduce(into: [Device]()) { devices, runtimeAndDevices in
                            let (runtime, deviceDictionaries) = runtimeAndDevices
                            try deviceDictionaries.forEach { deviceDictionary in
                                var deviceDictionary = deviceDictionary
                                deviceDictionary["runtimeName"] = runtime
                                let deviceData = try JSONSerialization.data(withJSONObject: deviceDictionary, options: [])
                                devices.append(try decoder.decode(Device.self, from: deviceData))
                            }
                        }
                        return Result.success(devices)
                    } catch {
                        return Result.failure(SimulatorError.jsonDecode(error))
                    }
                }
        }
    }
}
