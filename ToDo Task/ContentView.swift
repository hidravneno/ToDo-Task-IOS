//
//  ContentView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 09/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var taskGroups = TaskGroup.sampleData // See MockData
    @State private var selectedGroup: TaskGroup? // selected group
    @State private var columnVisibility: NavigationSplitViewVisibility = .all // navigation side panel
    @State private var isShowingAddGroup = false

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
                Button {
                    isShowingAddGroup = true
                } label: {
                    Image(systemName: "plus")
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
                selectedGroup = newGroup // Automatically show up the deatails od the new group i created
            }
        }

    }
}
