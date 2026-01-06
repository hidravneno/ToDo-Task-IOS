//
//  CulturalConfiguration.swift
//  ToDo Task
//
//  Created for RTL and Cultural Support
//

import SwiftUI

struct CulturalConfiguration {
    let locale: Locale
    
    var isRTL: Bool {
        if let languageCode = locale.language.languageCode?.identifier {
            return Locale.Language(identifier: languageCode).characterDirection == .rightToLeft
        }
        return false
    }
    
    var buttonOrder: ButtonOrder {
        return isRTL ? .cancelRight : .cancelLeft
    }
    
    var accentColor: Color {
        switch locale.language.languageCode?.identifier {
        case "ar":
            return Color(red: 0.0, green: 0.5, blue: 0.4)
        case "he":
            return Color.blue
        case "es":
            return Color.orange
        case "fr":
            return Color.purple
        case "pl":
            return Color.red
        default:
            return Color.cyan
        }
    }
    
    var backgroundPattern: String? {
        switch locale.language.languageCode?.identifier {
        case "ar":
            return "arabicPattern"
        default:
            return nil
        }
    }
    
    var preferredFont: Font {
        switch locale.language.languageCode?.identifier {
        case "ar":
            return .system(.body, design: .rounded)
        default:
            return .body
        }
    }
    
    enum ButtonOrder {
        case cancelLeft  // [Cancel] [Save]
        case cancelRight // [Save] [Cancel]
    }
    
    init(locale: Locale = .current) {
        self.locale = locale
    }
}

// MARK: - Environment Key
struct CulturalConfigurationKey: EnvironmentKey {
    static let defaultValue = CulturalConfiguration()
}

extension EnvironmentValues {
    var culturalConfig: CulturalConfiguration {
        get { self[CulturalConfigurationKey.self] }
        set { self[CulturalConfigurationKey.self] = newValue }
    }
}
