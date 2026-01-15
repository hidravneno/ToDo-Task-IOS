//
//  PremiumManager.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 13/01/26.
//

import SwiftUI
import Combine

class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    @Published var isPremium: Bool = false
    
    // Limits for free users
    public let freeProfilesLimit = 3
    public let freeGroupsLimit = 5
    
    private let premiumKey = "isPremiumUser"
    
    init() {
        // Load premium status from UserDefaults
        self.isPremium = UserDefaults.standard.bool(forKey: premiumKey)
    }
    
    // Check if the user is premium
    func checkPremiumStatus() -> Bool {
        return isPremium
    }
    
    // Check if the user can create more profiles
    func canCreateProfile(currentCount: Int) -> Bool {
        if isPremium {
            return true // Premium = unlimited profiles
        }
        return currentCount < freeProfilesLimit // Free = max 3
    }
    
    // Check if the user can create more groups
    func canCreateGroup(currentCount: Int) -> Bool {
        if isPremium {
            return true // Premium = unlimited groups
        }
        return currentCount < freeGroupsLimit // Free = max 5
    }
    
    // Activate premium (simulated for development)
    func activatePremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
    }
    
    // Deactivate premium (for testing)
    func deactivatePremium() {
        isPremium = false
        UserDefaults.standard.set(false, forKey: premiumKey)
    }
    
    // Toggle for development
    func togglePremium() {
        if isPremium {
            deactivatePremium()
        } else {
            activatePremium()
        }
    }
}
