import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? // Firebase User object
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private var handle: AuthStateDidChangeListenerHandle?
        
        init() {
            // Listen for authentication state changes
            handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
                DispatchQueue.main.async {
                    self?.user = user
                    self?.isAuthenticated = user != nil
                    print("🔐 Auth state changed: \(user != nil ? "Authenticated" : "Not authenticated")")
                    if let user = user {
                        print("👤 User email: \(user.email ?? "No email")")
                    }
                }
            }
        }
        
        deinit {
            if let handle = handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.user = result?.user
            self?.isAuthenticated = true
            self?.errorMessage = nil
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.user = result?.user
            self?.isAuthenticated = true
            self?.errorMessage = nil
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
