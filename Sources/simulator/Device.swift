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

    // MARK: - Paths

    public func globalPreferencesPlistPath() -> URL {
        return homePath().appendingPathComponent("data/Library/Preferences/.GlobalPreferences.plist")
    }

    public func devicePlistPath() -> URL {
        return homePath().appendingPathComponent("device.plist")
    }

    public func homePath() -> URL {
        return Device.devicesPath().appendingPathComponent(udid)
    }

//    public func launchCtlPath() -> URL {
//        return self.runtimePath().appendingPathComponent("bin/launchctl")
//    }

//    public func runtimePath() -> URL {
//
//    }

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
