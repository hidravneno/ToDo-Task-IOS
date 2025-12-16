//
//  GroupStatsView.swift
//  ToDo Task
//
//  Created by francisco eduardo aramburo reyes on 11/12/25.
//

import SwiftUI

struct GroupStatsView: View {
    var tasks: [TaskItem]
    var completedCount: Int { tasks.filter {$0.isCompleted}.count }
    var progress: Double { tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count)}
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.cyan)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.cyan)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .bold()
            }
            .frame(width: 60, height: 60)
            .padding()
            
            VStack(alignment: .leading) {
                Text("Task Progress")
                    .font(.headline)
                Text("\(completedCount) / \(tasks.count) Completed")
            }
            
            Spacer()
        }
    }
}
