//
//  ContentView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 09/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var taskGroups: [TaskGroup] = []
    @State private var selectedGroup: TaskGroup? // selected group
    @State private var columnVisibility: NavigationSplitViewVisibility = .all // navigation side panel
    @State private var isShowingAddGroup = false
    @State private var colorScheme: ColorScheme? = nil // nil = automatic
    @Environment(\.scenePhase) private var scenePhase
    
    let saveKey = "savedTaskGroups"
    let themeKey = "savedTheme"

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // SIDEBAR
            List(selection: $selectedGroup) {
                ForEach(taskGroups) { group in
                    NavigationLink(value: group) {
                        Label(group.title, systemImage: group.symbolName)
                    }
                }
            }
            .navigationTitle("ToDo APP")
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigation) {
                    Menu {
                        Button {
                            colorScheme = nil
                            UserDefaults.standard.set("auto", forKey: themeKey)
                        } label: {
                            Label("Automatic", systemImage: "circle.lefthalf.filled")
                        }
                        
                        Button {
                            colorScheme = .light
                            UserDefaults.standard.set("light", forKey: themeKey)
                        } label: {
                            Label("Light", systemImage: "sun.max")
                        }
                        
                        Button {
                            colorScheme = .dark
                            UserDefaults.standard.set("dark", forKey: themeKey)
                        } label: {
                            Label("Dark", systemImage: "moon")
                        }
                    } label: {
                        Image(systemName: "circle.lefthalf.filled")
                    }
                }
            }
        } detail: {
            if let group = selectedGroup {
                if let index = taskGroups.firstIndex(where: { $0.id == group.id }) {
                    TaskGroupDetailView(groups: $taskGroups[index])
                }
            } else {
                ContentUnavailableView("Select a Group", systemImage: "sidebar.left")
            }
        }
        .sheet(isPresented: $isShowingAddGroup) {
            NewGroupView { newGroup in
                taskGroups.append(newGroup)
                selectedGroup = newGroup // Automatically show up the details of the new group i created
            }
        }
        .onAppear {
            loadData()
            // Load theme
            let theme = UserDefaults.standard.string(forKey: themeKey) ?? "auto"
            colorScheme = theme == "dark" ? .dark : theme == "light" ? .light : nil
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
        if let encodedData = try? JSONEncoder().encode(taskGroups) {
            UserDefaults.standard.set(encodedData, forKey: saveKey)
        }
    }
    
    func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedGroups = try? JSONDecoder().decode([TaskGroup].self, from: savedData) {
                taskGroups = decodedGroups
                return
            }
        }
        
        // show mock data for dev purposes
        taskGroups = TaskGroup.sampleData
    }
}
