//
//  TaskModels.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 09/12/25.
//

import Foundation

enum Priority: String, Codable, CaseIterable {
    case high
    case medium
    case low
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}


struct TaskItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var dueDate: Date? = nil
    var priority: Priority? = nil
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else {return false}
        return dueDate < Date()
    }
}

struct TaskGroup: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var symbolName: String
    var tasks: [TaskItem]
}

struct Profile: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var profileImage: String
    var groups: [TaskGroup]
}


// MOCK DATA
extension TaskGroup {
    static let sampleData: [TaskGroup] = [
        TaskGroup(title: "Groceries", symbolName: "storefront.circle.fill", tasks: [
            TaskItem(title: "Buy Apples"),
            TaskItem(title: "Buy Milk")
        ]),
        
        TaskGroup(title: "Home", symbolName: "house.fill", tasks: [
            TaskItem(title: "Walk the dog", isCompleted: true ),
            TaskItem(title: "Clean the kitchen")
        ])
    ]
}

extension Profile {
    static let sample: [Profile] = [
        Profile(name: "Professor", profileImage: "professor", groups: TaskGroup.sampleData),
        Profile(name: "Student", profileImage: "student", groups:[])

    ]
}
