//
//  ContentView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 09/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var profiles: [Profile] = []
    @AppStorage("savedTheme") private var savedTheme: String = "auto"
    @State private var colorScheme: ColorScheme? = nil
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var premiumManager = PremiumManager.shared
    
    // States for adding profiles and premium
    @State private var showAddProfileSheet = false
    @State private var showPremiumView = false
    @State private var showLimitAlert = false

    let saveKey = "savedProfile"
    @State private var path = NavigationPath()
    let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ZStack {
            CulturalBackgroundView()

            NavigationStack(path: $path) {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Select the working profile")
                            .font(.largeTitle.bold())
                            .accessibilityIdentifier("working_profile_title")
                            .padding(.top, 20)
                        
                        // Profile counter (free users only)
                        if !premiumManager.isPremium {
                            ProfileCounterBadge(
                                currentCount: profiles.count,
                                maxCount: premiumManager.freeProfilesLimit
                            )
                        }

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach($profiles) { $profile in
                                NavigationLink(value: profile.id) {
                                    ProfileCardView(profile: profile)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityIdentifier("profileCard_\(profile.name)")
                            }
                            
                            // Add profile button
                            AddProfileButton {
                                handleAddProfile()
                            }
                            .accessibilityIdentifier("addProfileButton")
                        }
                        .padding(.horizontal)
                        
                        // Premium button if not premium
                        if !premiumManager.isPremium {
                            Button {
                                showPremiumView = true
                            } label: {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Text("Upgrade to Premium")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .accessibilityIdentifier("upgradeToPremiumButton")
                        }
                        
                        // Premium toggle (development only)
                        #if DEBUG
                        Button {
                            premiumManager.togglePremium()
                        } label: {
                            Text(premiumManager.isPremium ? "✓ Premium Active - Deactivate (DEV)" : "☆ Activate Premium (DEV)")
                                .font(.caption)
                                .padding()
                                .background(premiumManager.isPremium ? Color.green.opacity(0.2) : Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                        .accessibilityIdentifier("togglePremiumButton")
                        #endif
                    }
                    .padding(.bottom, 20)
                }
                .navigationTitle("Home")
                .navigationBarHidden(true)
                .navigationDestination(for: UUID.self) { profileId in
                    if let index = profiles.firstIndex(where: { $0.id == profileId }) {
                        DashboardView(profile: $profiles[index])
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
        }
        .environment(\.culturalConfig, CulturalConfiguration())
        .sheet(isPresented: $showAddProfileSheet) {
            AddProfileView { newProfile in
                profiles.append(newProfile)
                saveData()
            }
        }
        .sheet(isPresented: $showPremiumView) {
            SimplePremiumView()
        }
        .overlay {
            if showLimitAlert {
                LimitAlertOverlay(
                    onUpgrade: {
                        showLimitAlert = false
                        showPremiumView = true
                    },
                    onDismiss: {
                        showLimitAlert = false
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            loadData()
            applyTheme()
        }
        .onChange(of: savedTheme) { _, _ in
            applyTheme()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .background {
                saveData()
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    // Handle adding profiles with limit
    private func handleAddProfile() {
        if premiumManager.canCreateProfile(currentCount: profiles.count) {
            showAddProfileSheet = true
        } else {
            withAnimation {
                showLimitAlert = true
            }
        }
    }

    func saveData() {
        if let encodedData = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encodedData, forKey: saveKey)
        }
    }

    func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decodedProfiles = try? JSONDecoder().decode([Profile].self, from: savedData) {
            profiles = decodedProfiles
            return
        }
        // Show mock data for development purposes
        profiles = Profile.sample
    }

    private func applyTheme() {
        switch savedTheme {
        case "dark":
            colorScheme = .dark
        case "light":
            colorScheme = .light
        default:
            colorScheme = nil // Automatic
        }
    }
}

// MARK: - Profile Counter Badge
struct ProfileCounterBadge: View {
    let currentCount: Int
    let maxCount: Int
    
    var isNearLimit: Bool {
        currentCount >= maxCount - 1
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.2.fill")
                .font(.caption)
            
            Text("\(currentCount)/\(maxCount) Profiles")
                .font(.caption.bold())
            
            if currentCount >= maxCount {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isNearLimit ? Color.orange.opacity(0.15) : Color.gray.opacity(0.15))
        .foregroundStyle(isNearLimit ? .orange : .secondary)
        .cornerRadius(20)
    }
}

// MARK: - Add Profile Button
struct AddProfileButton: View {
    let action: () -> Void
    @Environment(\.culturalConfig) var culturalConfig
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(culturalConfig.accentColor)
                
                Text("Add Profile")
                    .font(culturalConfig.preferredFont.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(culturalConfig.accentColor.opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Limit Alert Overlay
struct LimitAlertOverlay: View {
    let onUpgrade: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                VStack(spacing: 8) {
                    Text("Profile Limit Reached")
                        .font(.title2.bold())
                    
                    Text("You've reached the maximum of 3 profiles on the free plan. Upgrade to Premium to create unlimited profiles!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 12) {
                    Button {
                        onUpgrade()
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Premium")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Button {
                        onDismiss()
                    } label: {
                        Text("Maybe Later")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(30)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Add Profile View
struct AddProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var profileName = ""
    @State private var selectedImage = "professor"
    
    let profileImages = ["professor", "student"]
    var onSave: (Profile) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Name") {
                    TextField("Enter profile name", text: $profileName)
                }
                
                Section("Profile Image") {
                    HStack(spacing: 20) {
                        ForEach(profileImages, id: \.self) { imageName in
                            Button {
                                selectedImage = imageName
                            } label: {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedImage == imageName ? Color.cyan : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newProfile = Profile(
                            name: profileName.isEmpty ? "New Profile" : profileName,
                            profileImage: selectedImage,
                            groups: []
                        )
                        onSave(newProfile)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileCardView: View {
    let profile: Profile
    @Environment(\.culturalConfig) var culturalConfig

    var body: some View {
        VStack(spacing: 8) {
            Image(profile.profileImage)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(.circle)
                .overlay(
                    Circle()
                        .stroke(culturalConfig.accentColor, lineWidth: 2)
                )

            Text(profile.name)
                .font(culturalConfig.preferredFont.weight(.semibold))
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(culturalConfig.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CulturalBackgroundView: View {
    @Environment(\.culturalConfig) var culturalConfig

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)

            if let patternName = culturalConfig.backgroundPattern {
                Image(patternName)
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
}
