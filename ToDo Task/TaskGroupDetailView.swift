//
//  TaskGroupDetailView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 09/12/25.
//

import SwiftUI

struct TaskGroupDetailView: View {
    @Binding var groups: TaskGroup
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.culturalConfig) var culturalConfig
    
    var body: some View {
        VStack {
            if sizeClass == .regular {
                GroupStatsView(tasks: groups.tasks)
                    .padding(.top)
            }
            
            List {
                ForEach($groups.tasks) { $task in
                    //priority: Changed HStack to VStack to add priority row
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isCompleted ? culturalConfig.accentColor : .gray)
                                .onTapGesture {
                                    withAnimation {
                                        task.isCompleted.toggle()
                                    }
                                }
                            
                            TextField("Task Title", text: $task.title)
                                .font(culturalConfig.preferredFont)
                                .strikethrough(task.isCompleted)
                                .foregroundColor(task.isOverdue && !task.isCompleted ? .red : .primary)
                                .accessibilityIdentifier("taskTextField_\(task.id)")
                            
                            DatePicker("", selection: Binding(
                                get: { task.dueDate ?? Date() },
                                set: { task.dueDate = $0 }
                            ), displayedComponents: .date)
                            .labelsHidden()
                            .frame(width: 100)
                            .tint(task.isOverdue ? .red : culturalConfig.accentColor)
                            .background(task.isOverdue ? Color.red.opacity(0.1) : Color.clear)
                            .accessibilityIdentifier("taskDatePicker_\(task.id)")
                        }
                        
                        //priority: Added priority picker row
                        HStack {
                            PriorityPickerView(priority: $task.priority)
                            Spacer()
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { index in
                    groups.tasks.remove(atOffsets: index)
                }
            }
        }
        .navigationTitle(groups.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        groups.tasks.append(TaskItem(title: "", dueDate: nil))                    }
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
                .tint(culturalConfig.accentColor)
                .accessibilityIdentifier("addTaskButton")
            }
        }
    }
}

//priority: New view for priority selection
struct PriorityPickerView: View {
    @Binding var priority: Priority?
    
    var body: some View {
        Menu {
            Button {
                priority = nil
            } label: {
                Label("No Priority", systemImage: "minus.circle")
            }
            
            Divider()
            
            ForEach(Priority.allCases, id: \.self) { priorityLevel in
                Button {
                    priority = priorityLevel
                } label: {
                    Label(priorityLevel.displayName, systemImage: priorityIcon(for: priorityLevel))
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: priorityIcon(for: priority))
                    .foregroundStyle(priorityColor(for: priority))
                
                Text(priority?.displayName ?? "Priority")
                    .foregroundStyle(priority == nil ? .secondary : priorityColor(for: priority))
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priority == nil ? Color.gray.opacity(0.1) : priorityColor(for: priority).opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    //priority: Icon helper function
    private func priorityIcon(for priority: Priority?) -> String {
        guard let priority = priority else { return "flag" }
        
        switch priority {
        case .high:
            return "exclamationmark.3"
        case .medium:
            return "exclamationmark.2"
        case .low:
            return "exclamationmark"
        }
    }
    
    //priority: Color helper function
    private func priorityColor(for priority: Priority?) -> Color {
        guard let priority = priority else { return .gray }
        
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
}
