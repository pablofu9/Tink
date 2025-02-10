//
//  UserDefaults+Utils.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//



import Foundation

extension UserDefaults {

    /// Check for user defaults key existence
    /// - Parameter key: Key to check
    /// - Returns: <code>True</code> if the key exists or <code>false</code> in other case
    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    /// Set Codable object into UserDefaults or remove it if object is nil
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    public func set<T: Codable>(object: T?, forKey: String) {
        guard let object = object else {
            removeObject(forKey: forKey)
            synchronize()
            return
        }
        
        let jsonData = try! JSONEncoder().encode(object)

        set(jsonData, forKey: forKey)
        
        synchronize()
    }

    /// Get Codable object from UserDefaults
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    
    
    /// Get Codable object from UserDefaults
    /// - Parameters:
    ///   - objectType: Codable Object
    ///   - forKey: Key string
    /// - Returns: The object if it exists or nil in other case
    public func get<T: Codable>(objectType: T.Type, forKey: String) -> T? {
        guard let result = value(forKey: forKey) as? Data else {
            return nil
        }

        return try! JSONDecoder().decode(objectType, from: result)
    }
}

// DARK MODE
extension UserDefaults {
    struct UserDefaultsDarkMode {
        static let kDarkMode = "DarkMode"
    }
    
    var darkMode: Bool {
        get {
            return get(objectType: Bool.self, forKey: UserDefaultsDarkMode.kDarkMode) ?? false
        }
        set {
            set(object: newValue, forKey: UserDefaultsDarkMode.kDarkMode)
            synchronize()
        }
    }
}

extension UserDefaults {
    struct UserDefaultsProfile {
        static let kprofile = "Profile"
        static let kprofileImage = "ProfileImage"
    }
    
    var profileName: String {
        get {
            return get(objectType: String.self, forKey: UserDefaultsProfile.kprofile) ?? "Juan"
        }
        set {
            set(object: newValue, forKey: UserDefaultsProfile.kprofile)
            synchronize()
        }
    }
    
    var profileImage: String {
        get {
            return get(objectType: String.self, forKey: UserDefaultsProfile.kprofileImage) ?? ""
        }
        set {
            set(object: newValue, forKey: UserDefaultsProfile.kprofileImage)
            synchronize()
        }
    }
}

