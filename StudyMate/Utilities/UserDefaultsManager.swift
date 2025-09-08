import Foundation

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    private let userNameKey = "userName"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: userNameKey)
        }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
        }
    }
    
    private init() {
        self.userName = UserDefaults.standard.string(forKey: userNameKey) ?? ""
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }
    
    func saveUserName(_ name: String) {
        userName = name
        hasCompletedOnboarding = true
    }
    
    func reset() {
        userName = ""
        hasCompletedOnboarding = false
    }
}
