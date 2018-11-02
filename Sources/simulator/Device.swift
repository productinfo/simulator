import Foundation

/// Model that represents a device returned by simctl.
public class Device: Decodable, Equatable {
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
        return try list(shell: Shell.shared)
    }

    // MARK: - Internal

    /// Gets the list of devices from the system.
    ///
    /// - Parameter shell: Instance of shell to run the commands.
    /// - Returns: List of devices.
    /// - Throws: An error if the simctl command fails.
    static func list(shell: Shelling) throws -> [Device] {
        let data = try shell.simctl("list", "-j", "devices")
        let decoder = JSONDecoder()

        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let runtimes = dictionary["devices"] as? [String: [[String: Any]]] else {
            return []
        }

        return try runtimes.reduce(into: [Device]()) { devices, runtimeAndDevices in
            let (runtime, deviceDictionaries) = runtimeAndDevices
            try deviceDictionaries.forEach { deviceDictionary in
                var deviceDictionary = deviceDictionary
                deviceDictionary["runtimeName"] = runtime
                let deviceData = try JSONSerialization.data(withJSONObject: deviceDictionary, options: [])
                devices.append(try decoder.decode(Device.self, from: deviceData))
            }
        }
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
