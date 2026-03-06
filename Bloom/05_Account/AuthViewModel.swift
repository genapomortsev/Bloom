import SwiftUI
import Combine

final class AuthViewModel: ObservableObject {
    @AppStorage("isLoggedIn") private var storedIsLoggedIn: Bool = false
    @AppStorage("profileFullName") private var storedFullName: String = ""
    @AppStorage("profileBio") private var storedBio: String = ""
    @AppStorage("authUsername") private var storedUsername: String = ""

    @Published var isLoggedIn: Bool = false
    @Published var username: String = ""
    @Published var password: String = "" // Demo only; do not use for production
    @Published var fullName: String = ""
    @Published var bio: String = ""
    @Published var signInError: String? = nil

    init() {
        self.isLoggedIn = storedIsLoggedIn
        self.fullName = storedFullName
        self.bio = storedBio
        self.username = storedUsername
    }

    private func keyForFullName(username: String) -> String { "profileFullName_\(username)" }
    private func keyForBio(username: String) -> String { "profileBio_\(username)" }

    func createAccount() {
        // Simulate account creation
        storedUsername = username
        do {
            try KeychainHelper.savePassword(password, account: username)
        } catch {
            signInError = "Failed to securely save password. Please try again."
            return
        }
        storedIsLoggedIn = true
        isLoggedIn = true

        // Store profile fields per account
        let fullNameKey = keyForFullName(username: username)
        let bioKey = keyForBio(username: username)
        UserDefaults.standard.register(defaults: [fullNameKey: username, bioKey: ""]) // defaults if new
        let newFullName = UserDefaults.standard.string(forKey: fullNameKey) ?? username
        let newBio = UserDefaults.standard.string(forKey: bioKey) ?? ""
        fullName = newFullName
        bio = newBio
        // Also keep global mirrors for convenience
        storedFullName = fullName
        storedBio = bio
    }

    func signIn() {
        // Simulate sign-in
        do {
            let stored = try KeychainHelper.readPassword(account: username)
            if stored != nil && password == stored {
                storedIsLoggedIn = true
                isLoggedIn = true
                signInError = nil

                // Load profile fields specific to this account
                let fullNameKey = keyForFullName(username: username)
                let bioKey = keyForBio(username: username)
                fullName = UserDefaults.standard.string(forKey: fullNameKey) ?? username
                bio = UserDefaults.standard.string(forKey: bioKey) ?? ""
                // Keep global mirrors in sync
                storedFullName = fullName
                storedBio = bio
            } else {
                signInError = "Invalid username or password. Please try again."
            }
        } catch {
            signInError = "Unable to access Keychain. Please try again."
        }
    }

    func signOut() {
        storedIsLoggedIn = false
        isLoggedIn = false
    }

    func deleteAccount() {
        storedIsLoggedIn = false
        isLoggedIn = false
        username = ""
        password = ""

        storedUsername = ""
        do {
            try KeychainHelper.deletePassword(account: username)
        } catch {
            // Non-fatal: log or surface if needed
        }

        // Remove per-account profile fields
        let fullNameKey = keyForFullName(username: username)
        let bioKey = keyForBio(username: username)
        UserDefaults.standard.removeObject(forKey: fullNameKey)
        UserDefaults.standard.removeObject(forKey: bioKey)

        storedFullName = ""
        storedBio = ""
        fullName = ""
        bio = ""
    }

    /// Persist current profile fields to storage.
    func saveProfile() {
        let currentUsername = username
        let fullNameKey = keyForFullName(username: currentUsername)
        let bioKey = keyForBio(username: currentUsername)
        UserDefaults.standard.set(fullName, forKey: fullNameKey)
        UserDefaults.standard.set(bio, forKey: bioKey)
        // Keep global mirrors in sync for existing UI bindings
        storedFullName = fullName
        storedBio = bio
    }
}

