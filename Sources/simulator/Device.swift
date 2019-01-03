import Foundation
import Result
import Shell

/// Model that represents a device returned by simctl.
public struct Device: Decodable, Equatable {
    /// A string that summarizes the device availability.
    /// Example: (unavailable, runtime profile not found)
    public private(set) var availability: String

    /// True if the device is available.
    public private(set) var isAvailable: Bool?

    /// A string that represents the state of the device.
    /// Example: Shutdown
    public private(set) var state: String

    /// The name of the device.
    /// Example: Apple TV 4K
    public private(set) var name: String

    /// Device unique identifier.
    /// Example: B9AC1102-025F-4921-B39D-45E18D484FC4
    public private(set) var udid: String

    /// When the device is not available, this string contains
    /// a description of why the device is not available.
    /// If the device is available, this string is empty.
    public private(set) var availabilityError: String?

    /// Name of the device runtime.
    /// Example: iOS 12.1
    public private(set) var runtimeName: String

    /// True if the device is booted.
    public var isBooted: Bool { return state == "Booted" }

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
    /// - Returns: A result with the list of devices or a simulator error.
    public static func list() -> Result<[Device], SimulatorError> {
        let decoder = JSONDecoder()
        let outputResult = shell.captureSimctl(["list", "-j", "devices"])
        if outputResult.error != nil { return .failure(outputResult.error!) }

        let data = outputResult.value!.data(using: .utf8) ?? Data()
        let jsonResult = Result {
            try JSONSerialization.jsonObject(with: data, options: [])
        }.mapError(SimulatorError.jsonSerialize)
        if jsonResult.error != nil { return .failure(jsonResult.error!) }

        guard let dictionary = jsonResult.value! as? [String: Any],
            let runtimes = dictionary["devices"] as? [String: [[String: Any]]] else {
            return .failure(.invalidFormat)
        }
        return Result {
            try runtimes.reduce(into: [Device]()) { devices, runtimeAndDevices in
                let (runtime, deviceDictionaries) = runtimeAndDevices
                try deviceDictionaries.forEach { deviceDictionary in
                    var deviceDictionary = deviceDictionary
                    deviceDictionary["runtimeName"] = runtime
                    let deviceData = try JSONSerialization.data(withJSONObject: deviceDictionary, options: [])
                    devices.append(try decoder.decode(Device.self, from: deviceData))
                }
            }
        }.mapError(SimulatorError.jsonDecode)
    }

    /// Returns the device runtime platform.
    ///
    /// - Returns: Device runtime platform or simulator error.
    public func runtimePlatform() -> Result<Runtime.Platform, SimulatorError> {
        return runtime().map({ $0.platform })
    }

    /// Launches the device.
    ///
    /// - Returns: A result with an error if the device cannot be launched.
    public func launch() -> Result<Void, SimulatorError> {
        let xcodePathResult = shell.xcodePath()
        if xcodePathResult.error != nil { return .failure(xcodePathResult.error!) }
        return shell.open(["-Fgn", "\(xcodePathResult.value!.path)/Applications/Simulator.app", "--args", "-CurrentDeviceUDID", udid])
    }

    /// Launches the given app from the device.
    ///
    /// - Parameter bundleIdentifier: The app bundle identifier.
    /// - Returns: A result with an error if the app could not be launched.
    public func launchApp(_ bundleIdentifier: String) -> Result<Void, SimulatorError> {
        return shell.runSimctl(["launch", udid, bundleIdentifier])
    }

    /// Kills the device. It findes the process associated to it and kills it.
    ///
    /// - Returns: True if the device was killed.
    /// = Returns: A result with a boolean that indicates whether the device has been killed or not, or a simulator error.
    @discardableResult
    public func kill() -> Result<Bool, SimulatorError> {
        let argument = "ps xww | grep Simulator.app | grep -s \(udid) | grep -v grep | awk '{print $1}'"
        let killResult = shell.capture(["/bin/bash", "-c", argument]).mapError(SimulatorError.shell)
        if killResult.error != nil { return .failure(killResult.error!) }

        guard let pid = Int(killResult.value!.chomp()) else {
            return .success(false)
        }
        return shell.sync(["/bin/kill", "\(pid)"]).map({ _ in true }).mapError(SimulatorError.shell)
    }

    /// Installs the given app on the device.
    ///
    /// - Parameter path: Path to the app bundle (with .app extension)
    /// - Returns: A result with an error if the app can't be installed.
    public func install(_ path: URL) -> Result<Void, SimulatorError> {
        return shell.runSimctl(["install", udid, path.path])
    }

    /// Uninstalls the given app from the device.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: The app bundle identifier.
    /// - Returns: A result with an error if the app can't be uninstalled.
    func uninstall(_ bundleIdentifier: String) -> Result<Void, SimulatorError> {
        return shell.runSimctl(["uninstall", udid, bundleIdentifier])
    }

    /// Erases the device content.
    ///
    /// - Returns: A result with an error if the simulator can't be erased.
    func erase() -> Result<Void, SimulatorError> {
        return shell.runSimctl(["erase", udid])
    }

    /// Returns the type of device reading the value from the device plist file.
    ///
    /// - Returns: The device type or an error if the device plist cannot be opened or the device type is missing.
    public func deviceType() -> Result<String, SimulatorError> {
        return plist().flatMap({ (content) -> Result<String, SimulatorError> in
            guard let deviceType = content["deviceType"] as? String else {
                return .failure(.deviceTypeNotFound)
            }
            return .success(deviceType)
        })
    }

    /// Returns the device runtime identifier.
    ///
    /// - Returns: The device runtime identifier or an error if the device plist cannot be opened or the runtime identifier is missing.
    public func runtimeIdentifier() -> Result<String, SimulatorError> {
        return plist().flatMap({ (content) -> Result<String, SimulatorError> in
            guard let runtime = content["runtime"] as? String else {
                return .failure(.runtimeNotFound)
            }
            return .success(runtime)
        })
    }

    /// Returns the device global preferences.
    ///
    /// - Returns: Device global preferences or a simulator error.
    public func globalPreferences() -> Result<[String: Any], SimulatorError> {
        return Result {
            let data = try Data(contentsOf: globalPreferencesPlistPath())
            return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        }.mapError(SimulatorError.plistSerialize)
    }

    /// Returns the  device device.plist content.
    ///
    /// - Returns: The device  plist  content or a simulator error.
    public func plist() -> Result<[String: Any], SimulatorError> {
        return Result {
            let data = try Data(contentsOf: devicePlistPath())
            return try PropertyListSerialization.propertyList(from: data,
                                                              options: [],
                                                              format: nil) as! [String: Any]
        }.mapError(SimulatorError.plistSerialize)
    }

    /// Returns the device runtime.
    ///
    /// - Returns: Result with the runtime or a simulator error.
    public func runtime() -> Result<Runtime, SimulatorError> {
        let runtimeIdentifierResult = runtimeIdentifier()
        if runtimeIdentifierResult.error != nil {
            return .failure(runtimeIdentifierResult.error!)
        }

        return Runtime.list().flatMap { (list) -> Result<Runtime, SimulatorError> in
            guard let runtime = list.first(where: { $0.identifier == runtimeIdentifierResult.value! }) else {
                return .failure(.runtimeNotFound)
            }
            return .success(runtime)
        }
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
    /// - Returns: Runtime path or a simulator error.
    public func runtimePath() -> Result<URL, SimulatorError> {
        return runtimePath(xcode: Xcode())
    }

    /// Returns the path to the runtime launchctl binary.
    ///
    /// - Returns: Path to the launchctl binary or a simulator error.
    public func launchCtlPath() -> Result<URL, SimulatorError> {
        return runtimePath().map({ $0.appendingPathComponent("bin/launchctl") })
    }

    /// Returns all the services that are available on this device.
    ///
    /// - Returns: List of services or a simulator error if the launchctl path cannot be obtained or the output is invalid.
    public func services() -> Result<[Service], SimulatorError> {
        let launchCtlPathResult = launchCtlPath()
        if launchCtlPathResult.error != nil {
            return .failure(launchCtlPathResult.error!)
        }

        let result = shell.capture([launchCtlPathResult.value!.path, "list"]).mapError(SimulatorError.shell)
        if result.error != nil { return .failure(result.error!) }

        let services = result.value!.split(separator: "\n")
            .dropFirst()
            .compactMap({ (line) -> Service? in
                let components = line.split(separator: "\t")
                if components.count != 3 { return nil }
                let pid = String(components[0])
                let status = Int(components[1])!
                let label = String(components[2])
                return Service(pid: pid, status: status, label: label)
            })
        return .success(services)
    }

    /// It reloads the device state until a certain condition is met.
    ///
    /// - Parameters:
    ///   - timeout: Timeout period after which the method returns an error if the condition hasn't been met.
    ///   - until: Condition that needs to be met in order fot the method to return.
    /// - Returns: A result with an error if it times out or the device state can't be reloaded.
    public mutating func wait(timeout: TimeInterval = 30, until: (Device) -> Bool) -> Result<Void, SimulatorError> {
        let timeoutDate = Date().addingTimeInterval(timeout)

        while true {
            sleep(1)
            let reloadResult = reload()
            if reloadResult.error != nil {
                return reloadResult
            }
            if until(self) {
                break
            } else if Date() > timeoutDate {
                return .failure(SimulatorError.timeoutError)
            }
        }
        return .success(())
    }

    /// Reloads the device's attributes and syncs them with the simctl output.
    ///
    /// - Returns: A result with an error if the device can't be obtained from simctl.
    public mutating func reload() -> Result<Void, SimulatorError> {
        let listResult = Device.list()
        if listResult.error != nil { return .failure(listResult.error!) }

        guard let device = listResult.value!.first(where: { $0.udid == udid }) else { return .success(()) }
        availability = device.availability
        state = device.state
        isAvailable = device.isAvailable
        name = device.name
        udid = device.udid
        availabilityError = device.availabilityError
        runtimeName = device.runtimeName
        return .success(())
    }

    // MARK: - Internal

    /// Returns the runtime path.
    ///
    /// - Parameter xcode: Xcode instance to read Xcode variables.
    /// - Returns: Runtime path or a simulator error.
    func runtimePath(xcode: Xcoding) -> Result<URL, SimulatorError> {
        let fileManager = FileManager.default
        let runtimeIdentifierResult = runtimeIdentifier()
        if runtimeIdentifierResult.error != nil {
            return .failure(runtimeIdentifierResult.error!)
        }

        // We check the runtimes in the Xcode profiles directory and the developer CoreSimulator folder
        var pathsToCheck: [URL] = []

        let runtimeResult = runtime()
        if runtimeResult.error != nil {
            return .failure(runtimeResult.error!)
        }

        let runtimeProfilesPathResult = xcode.runtimeProfilesPath(platform: runtimeResult.value!.platform)
        if runtimeProfilesPathResult.error != nil {
            return .failure(runtimeProfilesPathResult.error!)
        }
        if let path = runtimeProfilesPathResult.value! {
            pathsToCheck.append(path)
        }
        pathsToCheck.append(URL(fileURLWithPath: "/Library/Developer/CoreSimulator/Profiles/Runtimes/"))
        let pathsResult = Result {
            try pathsToCheck.flatMap { try fileManager.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil, options: []) }
        }.mapError(SimulatorError.fileManager)
        if pathsResult.error != nil {
            return .failure(pathsResult.error!)
        }

        // We check that the the runtime bundle identifier matches the device runtime id.
        for path in pathsResult.value! {
            let plistPath = path.appendingPathComponent("Contents/Info.plist")
            if !fileManager.fileExists(atPath: plistPath.path) {
                continue
            }
            let plistResult: Result<Any, SimulatorError> = Result {
                let plistData = try Data(contentsOf: plistPath)
                return try PropertyListSerialization.propertyList(from: plistData,
                                                                  options: [],
                                                                  format: nil)
            }.mapError(SimulatorError.plistSerialize)

            if plistResult.error != nil {
                return .failure(plistResult.error!)
            }

            guard let plist = plistResult.value! as? [String: Any],
                let bundleIdentifier = plist["CFBundleIdentifier"] as? String else {
                continue
            }
            if bundleIdentifier != runtimeIdentifierResult.value! {
                continue
            }
            let rootPath = path.appendingPathComponent("Contents/Resources/RuntimeRoot")
            if fileManager.fileExists(atPath: rootPath.path) {
                return .success(rootPath)
            }
        }
        return .failure(.runtimeProfileNotFound)
    }

    // MARK: - Static

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
}
