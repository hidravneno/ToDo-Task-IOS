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
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .accessibilityIdentifier("taskTextField_\(task.id)")
                        
                        DatePicker("", selection: Binding(
                            get: { task.dueDate ?? Date() },
                            set: { task.dueDate = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .frame(width: 100)
                        .accessibilityIdentifier("taskDatePicker_\(task.id)")
                    }
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
