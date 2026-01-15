//
//  SimplePremiumView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 14/01/26.
//


import SwiftUI

struct SimplePremiumView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.culturalConfig) var culturalConfig
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Premium icon
                    Image(systemName: "crown.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 40)
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("Upgrade to Premium")
                            .font(.system(.title, design: .rounded, weight: .bold))
                        
                        Text("Create unlimited profiles and boost your productivity")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Free vs Premium comparison
                    VStack(spacing: 20) {
                        
                        // FREE
                        ComparisonCard(
                            title: "Free",
                            features: [
                                "Up to 3 profiles",
                                "Basic features",
                                "Standard themes"
                            ],
                            price: "Free",
                            isPremium: false,
                            accentColor: .gray
                        )
                        
                        // PREMIUM
                        ComparisonCard(
                            title: "Premium",
                            features: [
                                "Unlimited profiles",
                                "All features unlocked",
                                "Custom themes",
                                "Priority support"
                            ],
                            price: "$4.99/month",
                            isPremium: true,
                            accentColor: culturalConfig.accentColor
                        )
                    }
                    .padding(.horizontal)
                    
                    // Upgrade button (simulated)
                    Button {
                        // In production, this is where the real purchase would happen
                        premiumManager.activatePremium()
                        dismiss()
                    } label: {
                        Text("Start Premium Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [culturalConfig.accentColor,
                                             culturalConfig.accentColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Development note
                    Text("Note: This is a development version. In production, this would process a real payment.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Comparison Card
struct ComparisonCard: View {
    let title: String
    let features: [String]
    let price: String
    let isPremium: Bool
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            HStack {
                Text(title)
                    .font(.title2.bold())
                
                Spacer()
                
                if isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            
            Divider()
            
            // Features
            VStack(alignment: .leading, spacing: 12) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(isPremium ? accentColor : .gray)
                        
                        Text(feature)
                            .font(.body)
                    }
                }
            }
            
            Divider()
            
            // Price
            Text(price)
                .font(.title3.bold())
                .foregroundStyle(isPremium ? accentColor : .secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPremium ? accentColor : Color.clear, lineWidth: 2)
        )
        .cornerRadius(16)
    }
}
