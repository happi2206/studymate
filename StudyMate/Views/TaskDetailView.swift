import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: TaskBase
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    var onEdit: (TaskBase) -> Void
    var onDelete: (TaskBase) -> Void
    var onToggleComplete: (TaskBase) -> Void
    
    private var subjectColor: Color {
        switch task.subject.lowercased() {
        case "it": return .blue
        case "math": return .purple
        case "history": return .orange
        case "design": return .pink
        default: return .gray
        }
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    private var statusColor: Color {
        if task.isCompleted { return .green }
        if task.isOverdue() { return .red }
        if Calendar.current.isDateInToday(task.dueDate) { return .blue }
        return .secondary
    }
    
    private var statusText: String {
        if task.isCompleted { return "Completed" }
        if task.isOverdue() { return "Overdue" }
        if Calendar.current.isDateInToday(task.dueDate) { return "Due Today" }
        return "Upcoming"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [subjectColor.opacity(0.05), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with task title and status
                        VStack(spacing: 16) {
                            // Task title
                            Text(task.title)
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .strikethrough(task.isCompleted)
                            
                            // Status badge
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 8, height: 8)
                                Text(statusText)
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(statusColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(statusColor.opacity(0.1))
                            )
                        }
                        .padding(.top, 20)
                        
                        // Task details card
                        VStack(spacing: 20) {
                            // Subject and Priority row
                            HStack(spacing: 16) {
                                // Subject
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Subject")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(subjectColor)
                                            .frame(width: 12, height: 12)
                                        Text(task.subject)
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(subjectColor)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(subjectColor.opacity(0.1))
                                    )
                                }
                                
                                // Priority
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Priority")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(priorityColor)
                                            .frame(width: 12, height: 12)
                                        Text(String(describing: task.priority).capitalized)
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(priorityColor)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(priorityColor.opacity(0.1))
                                    )
                                }
                            }
                            
                            // Due date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Due Date")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.dueDate, style: .date)
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text(task.dueDate, style: .time)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                            
                            // Notes section
                            if !task.details.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Text(task.details)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                        )
                                }
                            }
                            
                            // Task type specific details
                            if let assignmentTask = task as? AssignmentTask, let submissionLink = assignmentTask.submissionLink {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Submission Link")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Link(destination: submissionLink) {
                                        HStack {
                                            Image(systemName: "link")
                                                .font(.system(size: 16, weight: .medium))
                                            Text(submissionLink.absoluteString)
                                                .font(.system(.body, design: .rounded))
                                                .lineLimit(1)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                    }
                                }
                            }
                            
                            if let examTask = task as? ExamTask, let location = examTask.location {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "location")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text(location)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                            }
                            
                            if let readingTask = task as? ReadingTask, let chapterRange = readingTask.chapterRange {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Chapter Range")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "book")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text(chapterRange)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            // Complete/Incomplete button
                            Button(action: { onToggleComplete(task) }) {
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20, weight: .medium))
                                    Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(task.isCompleted ? Color.gray : Color.green)
                                )
                            }
                            
                            // Edit and Delete buttons
                            HStack(spacing: 16) {
                                Button(action: { showingEdit = true }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Edit")
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(subjectColor)
                                    )
                                }
                                
                                Button(action: { showingDeleteAlert = true }) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Delete")
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.red)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Bottom padding
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button("Done") { dismiss() }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                    .padding(.trailing, 20)
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditTaskView(task: task) { updatedTask in
                onEdit(updatedTask)
                dismiss()
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
}

#Preview {
    TaskDetailView(
        task: AssignmentTask(
            title: "Complete iOS App Assignment",
            details: "Build a SwiftUI app with MVVM architecture and implement user authentication",
            subject: "IT",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            priority: .high,
            submissionLink: URL(string: "https://github.com/example/assignment")
        ),
        onEdit: { _ in },
        onDelete: { _ in },
        onToggleComplete: { _ in }
    )
}
