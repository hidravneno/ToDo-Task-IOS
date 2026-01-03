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
    
    let saveKey = "savedProfile"
    @State private var path = NavigationPath()
    let columns = [GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Select the working profile")
                        .font(.largeTitle.bold())
                        .padding(.top, 20)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach($profiles) { $profile in
                            NavigationLink(value: profile.id) {
                                VStack(spacing: 8) {
                                    Image(profile.profileImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(.circle)
                                    Text(profile.name)
                                        .font(.headline)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
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
        .onAppear {
            loadData()
            applyTheme()
        }
        .onChange(of: savedTheme) { _, _ in
            applyTheme()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                print("App is Active and running")
            } else if newValue == .inactive {
                print("App is inactive /not used right now")
            } else if newValue == .background {
                print("App is in background mode")
                saveData()
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    func saveData() {
        if let encodedData = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encodedData, forKey: saveKey)
        }
    }
    
    func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedProfiles = try? JSONDecoder().decode([Profile].self, from: savedData) {
                profiles = decodedProfiles
                return
            }
        }
        // Show mock data for dev purposes
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
