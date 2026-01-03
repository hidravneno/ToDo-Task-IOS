//
//  DashboardView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 20/12/25.
//

import SwiftUI
import Combine

struct DashboardView: View {
    
    @Binding var profile: Profile
    @State private var selectedGroup: TaskGroup?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isShowingAddGroup = false
    @State private var isShowingSettings = false
    @Environment(\.dismiss) var dismiss
    
    // Theme state
    @AppStorage("savedTheme") private var savedTheme: String = "auto"
    @State private var colorScheme: ColorScheme? = nil
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedGroup) {
                ForEach(profile.groups) { group in
                    NavigationLink(value: group) {
                        Label(group.title, systemImage: group.symbolName)
                    }
                }
            }
            .navigationTitle(profile.name)
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Home")
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        } detail: {
            if let group = selectedGroup {
                if let index = profile.groups.firstIndex(where: { $0.id == group.id }) {
                    TaskGroupDetailView(groups: $profile.groups[index])
                }
            } else {
                ContentUnavailableView("Select a Group", systemImage: "sidebar.left")
            }
        }
        .sheet(isPresented: $isShowingAddGroup) {
            NewGroupView { newGroup in
                profile.groups.append(newGroup)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .preferredColorScheme(colorScheme)
        .onAppear {
            applyTheme()
        }
        .onChange(of: savedTheme) { _, _ in
            applyTheme()
        }
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

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("savedTheme") private var savedTheme: String = "auto"
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $savedTheme) {
                        Label("Automatic", systemImage: "circle.lefthalf.filled")
                            .tag("auto")
                        Label("Light", systemImage: "sun.max")
                            .tag("light")
                        Label("Dark", systemImage: "moon")
                            .tag("dark")
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Regional Formats") {
                    LocalizedFormatsView()
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Localized Formats View
struct LocalizedFormatsView: View {
    @State private var currentDate = Date()
    let sampleNumber = 1234567.89
    let completedTasks = 42
    let totalTasks = 100
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currentDate, formatter: dateFormatter)
                    .font(.body)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currentDate, formatter: timeFormatter)
                    .font(.body)
                    .monospacedDigit()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Sample Number")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatNumber(sampleNumber))
                    .font(.body)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Task Completion")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatPercentage(Double(completedTasks) / Double(totalTasks)))
                    .font(.body)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Locale")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Locale.current.identifier)")
                    .font(.body)
                    .foregroundStyle(.blue)
            }
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale.current
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.locale = Locale.current
        return formatter
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value * 100)%"
    }
}
