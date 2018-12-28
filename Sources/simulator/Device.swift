import Foundation

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
    /// - Returns: List of devices.
    /// - Throws: An error if the simctl command fails.
    public static func list() throws -> [Device] {
        let decoder = JSONDecoder()
        let output = try shell.captureSimctl(["list", "-j", "devices"])

        let data = output.data(using: .utf8) ?? Data()
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any],
            let runtimes = dictionary["devices"] as? [String: [[String: Any]]] else {
            throw SimulatorError.invalidFormat
        }
        let devices = try runtimes.reduce(into: [Device]()) { devices, runtimeAndDevices in
            let (runtime, deviceDictionaries) = runtimeAndDevices
            try deviceDictionaries.forEach { deviceDictionary in
                var deviceDictionary = deviceDictionary
                deviceDictionary["runtimeName"] = runtime
                let deviceData = try JSONSerialization.data(withJSONObject: deviceDictionary, options: [])
                devices.append(try decoder.decode(Device.self, from: deviceData))
            }
        }
        return devices
    }

    /// Returns the device runtime platform.
    ///
    /// - Returns: Device runtime platform.
    /// - Throws: An error if the runtime can't be obtained.
    public func runtimePlatform() throws -> Runtime.Platform {
        return try runtime().platform
    }

    /// Launches the device.
    ///
    /// - Throws: An error if the device cannot be launched.
    public func launch() throws {
        try shell.open(["-Fgn", "\(shell.xcodePath().path)/Applications/Simulator.app", "--args", "-CurrentDeviceUDID", udid])
    }

    /// Launches the given app from the device.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: The app bundle identifier.
    /// - Throws: An error if the app cannot be launched.
    public func launchApp(_ bundleIdentifier: String) throws {
        try shell.runSimctl(["launch", udid, bundleIdentifier])
    }

    /// Kills the device. It findes the process associated to it and kills it.
    ///
    /// - Returns: True if the device was killed.
    /// - Throws: An error if any of the underlying commands fails.
    @discardableResult
    public func kill() throws -> Bool {
        let argument = "ps xww | grep Simulator.app | grep -s \(udid) | grep -v grep | awk '{print $1}'"
        let result = try shell.capture(["/bin/bash", "-c", argument])
        try result.throwIfFailed()

        guard let pid = Int(result.stdout!.chomp()) else {
            return false
        }
        let killOutput = try shell.sync(["/bin/kill", "\(pid)"])
        return killOutput.code == 0
    }

    /// Installs the given app on the device.
    ///
    /// - Parameters:
    ///   - path: Path to the app bundle (with .app extension)
    /// - Throws: An error if the app cannot be installed
    public func install(_ path: URL) throws {
        try shell.runSimctl(["install", udid, path.path])
    }

    /// Uninstalls the given app from the device.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: The app bundle identifier.
    /// - Throws: An error if the app cannot be uninstalled.
    func uninstall(_ bundleIdentifier: String) throws {
        try shell.runSimctl(["uninstall", udid, bundleIdentifier])
    }

    /// Erases the device content.
    ///
    /// - Throws: An error if the device cannot be erased.
    func erase() throws {
        try shell.runSimctl(["erase", udid])
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

    /// Returns all the services that are available on this device.
    ///
    /// - Returns: List of services.
    /// - Throws: An error if the launchctl path cannot be obatined or the output is invalid.
    public func services() throws -> [Service] {
        let output = try shell.capture([try launchCtlPath().path, "list"])
        try output.throwIfFailed()
        return try output.stdout!.split(separator: "\n")
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

    /// It reloads the device state until a certain condition is met.
    ///
    /// - Parameters:
    ///   - timeout: Timeout period after which the method throws if the condition hasn't been met.
    ///   - until: Condition that needs to be met in order fot the method to return.
    /// - Throws: An error if the method times out.
    public mutating func wait(timeout: TimeInterval = 30, until: (Device) -> Bool) throws {
        let timeoutDate = Date().addingTimeInterval(timeout)

        while true {
            sleep(1)
            try reload()
            if until(self) {
                break
            } else if Date() > timeoutDate {
                throw SimulatorError.timeoutError
            }
        }
    }

    /// Reloads the device's attributes and syncs them with the simctl output.
    ///
    /// - Throws: An error if the device can't be obtained from simctl.
    public mutating func reload() throws {
        let list = try Device.list()
        guard let device = list.first(where: { $0.udid == udid }) else { return }
        availability = device.availability
        state = device.state
        isAvailable = device.isAvailable
        name = device.name
        udid = device.udid
        availabilityError = device.availabilityError
        runtimeName = device.runtimeName
    }

    // MARK: - Internal

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

        if let path = try xcode.runtimeProfilesPath(platform: self.runtime().platform) {
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
