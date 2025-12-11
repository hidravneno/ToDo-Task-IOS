//
//  TaskGroupDetailView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 09/12/25.
//

import SwiftUI

struct TaskGroupDetailView: View {
    @Binding var groups: TaskGroup
    
    var body: some View {
        List {
            ForEach($groups.tasks) { $task in
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .cyan : .gray)
                        .onTapGesture {
                            withAnimation {
                                task.isCompleted.toggle()
                            }
                        }
                    
                    TextField("Task Title", text: $task.title)
                        .strikethrough(task.isCompleted)
                }
            }
            .onDelete { index in
                groups.tasks.remove(atOffsets: index)
            }
        }
        .navigationTitle(groups.title)
        .toolbar {
            Button("Add Task") {
                withAnimation {
                    groups.tasks.append(TaskItem(title: ""))
                }
            }
        }
    }
}
