//
//  DashboardView.swift
//  ToDo Task
//
//  Con límites premium para grupos
//

import SwiftUI
import Combine

struct DashboardView: View {
    
    @Binding var profile: Profile
    @State private var selectedGroup: TaskGroup?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isShowingAddGroup = false
    @State private var isShowingSettings = false
    @State private var showPremiumView = false
    @State private var showGroupLimitAlert = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.culturalConfig) var culturalConfig
    @ObservedObject private var premiumManager = PremiumManager.shared
    
    // Theme state
    @AppStorage("savedTheme") private var savedTheme: String = "auto"
    @State private var colorScheme: ColorScheme? = nil
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedGroup) {
                // Premium status banner (solo si no es premium)
                if !premiumManager.isPremium {
                    Section {
                        PremiumBannerButton {
                            showPremiumView = true
                        }
                    }
                    .listRowBackground(Color.clear)
                    
                    // Group counter
                    Section {
                        GroupCounterBadge(
                            currentCount: profile.groups.count,
                            maxCount: premiumManager.freeGroupsLimit
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                // Groups list
                Section {
                    ForEach(profile.groups) { group in
                        NavigationLink(value: group) {
                            HStack {
                                Label(group.title, systemImage: group.symbolName)
                                    .foregroundColor(culturalConfig.accentColor)
                                
                                Spacer()
                                
                                // Task count badge
                                Text("\(group.tasks.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .accessibilityIdentifier("groupRow_\(group.title)")
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
                        handleAddGroup()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            if !premiumManager.isPremium && profile.groups.count >= premiumManager.freeGroupsLimit {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .accessibilityIdentifier("addGroupButton")
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "gearshape")
                            if premiumManager.isPremium {
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
            SettingsView(onShowPremium: {
                isShowingSettings = false
                showPremiumView = true
            })
        }
        .sheet(isPresented: $showPremiumView) {
            SimplePremiumView()
        }
        .overlay {
            if showGroupLimitAlert {
                GroupLimitAlert(
                    onUpgrade: {
                        showGroupLimitAlert = false
                        showPremiumView = true
                    },
                    onDismiss: {
                        showGroupLimitAlert = false
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .preferredColorScheme(colorScheme)
        .environment(\.culturalConfig, CulturalConfiguration())
        .onAppear {
            applyTheme()
        }
        .onChange(of: savedTheme) { _, _ in
            applyTheme()
        }
    }
    
    private func handleAddGroup() {
        if premiumManager.canCreateGroup(currentCount: profile.groups.count) {
            isShowingAddGroup = true
        } else {
            withAnimation {
                showGroupLimitAlert = true
            }
        }
    }
    
    private func applyTheme() {
        switch savedTheme {
        case "dark":
            colorScheme = .dark
        case "light":
            colorScheme = .light
        default:
            colorScheme = nil
        }
    }
}

// MARK: - Premium Banner Button
struct PremiumBannerButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade to Premium")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Unlimited groups & tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Group Counter Badge
struct GroupCounterBadge: View {
    let currentCount: Int
    let maxCount: Int
    
    var isNearLimit: Bool {
        currentCount >= maxCount - 1
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.badge.plus")
                .font(.caption)
            
            Text("\(currentCount)/\(maxCount) Groups")
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
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isNearLimit ? Color.orange.opacity(0.15) : Color.gray.opacity(0.15))
        .foregroundStyle(isNearLimit ? .orange : .secondary)
        .cornerRadius(20)
    }
}

// MARK: - Group Limit Alert
struct GroupLimitAlert: View {
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
                Image(systemName: "folder.fill.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                VStack(spacing: 8) {
                    Text("Group Limit Reached")
                        .font(.title2.bold())
                    
                    Text("You've reached the maximum of 5 groups on the free plan. Upgrade to Premium for unlimited groups!")
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

// MARK: - Settings View Actualizado
struct SettingsView: View {
    @AppStorage("savedTheme") private var savedTheme: String = "auto"
    @Environment(\.dismiss) var dismiss
    @Environment(\.culturalConfig) var culturalConfig
    @ObservedObject private var premiumManager = PremiumManager.shared
    var onShowPremium: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // Premium section
                if premiumManager.isPremium {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Premium Active")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                } else {
                    Section {
                        Button {
                            onShowPremium()
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
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upgrade to Premium")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Unlock unlimited features")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
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
                
                Section("Cultural Settings") {
                    HStack {
                        Text("Layout Direction")
                        Spacer()
                        Text(culturalConfig.isRTL ? "Right to Left" : "Left to Right")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Accent Color")
                        Spacer()
                        Circle()
                            .fill(culturalConfig.accentColor)
                            .frame(width: 20, height: 20)
                    }
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Development toggle
                #if DEBUG
                Section("Development") {
                    Button {
                        premiumManager.togglePremium()
                    } label: {
                        HStack {
                            Text(premiumManager.isPremium ? "Deactivate Premium" : "Activate Premium")
                            Spacer()
                            Image(systemName: premiumManager.isPremium ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(premiumManager.isPremium ? .green : .gray)
                        }
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: culturalConfig.buttonOrder == .cancelRight ? .confirmationAction : .cancellationAction) {
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
    @Environment(\.culturalConfig) var culturalConfig
    
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
                    .font(culturalConfig.preferredFont)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currentDate, formatter: timeFormatter)
                    .font(culturalConfig.preferredFont)
                    .monospacedDigit()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Sample Number")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatNumber(sampleNumber))
                    .font(culturalConfig.preferredFont)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Task Completion")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatPercentage(Double(completedTasks) / Double(totalTasks)))
                    .font(culturalConfig.preferredFont)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Locale")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Locale.current.identifier)")
                    .font(culturalConfig.preferredFont)
                    .foregroundStyle(culturalConfig.accentColor)
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
