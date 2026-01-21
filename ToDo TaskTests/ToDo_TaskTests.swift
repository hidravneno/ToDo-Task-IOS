//
//  ToDo_TaskTests.swift
//  ToDo TaskTests
//
//  Created by francisco eduardo aramburo reyes on 20/01/26.
//

import Testing
import Foundation
@testable import ToDo_Task

struct Todo_TaskTests {
    
    /* Feature: Add a calendar next to a task to have a Due Date */
    
    @Test("Verify that the TaskItem can store and retrieve a due date")
    // AAA: Arrange, Act and Assert
    // Given, when, then
    
    func testTaskItemDueDate() {
        let testDate = Date(timeIntervalSince1970: 1735689600) // Jan 1, 2025
        
        let task = TaskItem(title: "Create Test Assignments", dueDate: testDate)
        
        #expect(task.dueDate == testDate)
    }
    
    
    // Show a visual alert/warning if a task is overdue
    
    @Test("Task should be identified as overdue if the due date is in the past")
    func testOverdueTaskLogic() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let task = TaskItem(title: "Submit my final report", isCompleted: false, dueDate: pastDate)
        
        #expect(task.isOverdue == true, "A task with a past date and not completed should be overdue")
    }
    
    
    }
    
    

   

