//
//  NewGroupView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 11/12/25.
//

import SwiftUI

struct NewGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var selectedIcon = "list.bullet"
    
    let icons = ["list.bullet", "bookmark.fill", "graduationcap.fill", "cart.fill", "house.fill", "heart.fill", "star.fill", "flag.fill"]
    
    // Recuerda: TaskGroup debe ser un struct definido en tu proyecto
    var onSave: (TaskGroup) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Group Name") {
                    TextField("Insert the name of your group", text: $groupName)
                        .accessibilityIdentifier("newGroupNameField")
                }
                
                Section("Select Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                // ADD UI DESIGN
                                .frame(width: 40, height: 40)
                                .background(selectedIcon == icon ? Color.cyan : Color.gray)
                                .cornerRadius(5)
                                .foregroundStyle(.white)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                                .accessibilityIdentifier("groupIcon_\(icon)")
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("New Group Creator")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelGroupButton")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newGroup = TaskGroup(title: groupName, symbolName: selectedIcon, tasks: [])
                        onSave(newGroup)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveGroupButton")
                }
            }
        }
    }
}
