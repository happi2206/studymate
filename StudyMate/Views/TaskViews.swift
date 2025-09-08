//
//  TaskViews.swift
//  StudyMate
//
//  Created by Happiness Adeboye on 4/9/2025.
//





import SwiftUI

// MARK: - Row

struct TaskRow: View {
    @ObservedObject var task: TaskBase
    var toggle: () -> Void

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
    
    private var rowBackgroundColor: Color {
        if task.isCompleted { return Color.gray.opacity(0.1) }
        if task.isOverdue() { return Color.red.opacity(0.1) }
        if Calendar.current
            .isDateInToday(task.dueDate) { return subjectColor.opacity(0.1) }
        return Color.white
    }

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox with custom styling
            Button(action: toggle) {
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? subjectColor : Color.clear)
                        .stroke(subjectColor, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .accessibilityLabel(
                task.isCompleted ? "Mark incomplete" : "Mark complete"
            )

            // Task content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(
                            task.isCompleted ? .secondary : .primary
                        )
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    // Priority indicator
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                }
                
                HStack {
                    // Subject badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(subjectColor)
                            .frame(width: 6, height: 6)
                        Text(task.subject)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(subjectColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(subjectColor.opacity(0.15))
                    .clipShape(Capsule())
                    
            Spacer()
                    
                    // Due date with icon
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(task.dueDate, style: .date)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(
                                task.isOverdue() ? .red : .secondary
                            )
                    }
                }
                
                // Task details if available
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(rowBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(subjectColor.opacity(0.2), lineWidth: 1)
        )
        .opacity(task.isCompleted ? 0.7 : 1)
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
    }
}

// MARK: - List View

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var showingAdd = false
    @State private var editingTask: TaskBase? = nil
    @State private var selectedTask: TaskBase? = nil
    @State private var showingClearAllAlert = false
    let userName: String

    init(userName: String = "Student") {
        self.userName = userName
        let repo = try? FileTaskRepository()
        _viewModel = StateObject(
            wrappedValue: TaskListViewModel(repository: repo!)
        )
    }
    
    private func addSampleTasks() {
        let subjects = ["IT", "Math", "History", "Design"]
        let now = Date()
        let oneDay: TimeInterval = 60 * 60 * 24
        
        let sampleTasks = [
            AssignmentTask(
                title: "Submit Project Proposal",
                details: "1-2 pages",
                subject: subjects[3],
                dueDate: now.addingTimeInterval(oneDay),
                priority: .high,
                submissionLink: nil
            ),
            ExamTask(
                title: "Algebra Midterm",
                details: "Ch 1-5",
                subject: subjects[1],
                dueDate: now.addingTimeInterval(oneDay * 3),
                priority: .high,
                location: "Room 204"
            ),
            ReadingTask(
                title: "Read Networking Basics",
                details: "Take notes",
                subject: subjects[0],
                dueDate: now.addingTimeInterval(oneDay * 2),
                priority: .medium,
                chapterRange: "Ch 2-3"
            ),
            ReadingTask(
                title: "WWII Overview",
                details: "Summary",
                subject: subjects[2],
                dueDate: now.addingTimeInterval(oneDay * 4),
                priority: .low,
                chapterRange: "pp. 45-60"
            )
        ]
        
        for task in sampleTasks {
            viewModel.add(task)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Header with stats
                        VStack(spacing: 16) {
                            // Welcome message on its own row
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hey \(userName)! 👋")
                                        .font(.system(.title, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    
                                    Text("Ready to tackle your studies today?")
                                        .font(
                                            .system(
                                                .subheadline,
                                                design: .rounded
                                            )
                                        )
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // Quick stats on their own row
                            HStack(spacing: 16) {
                                VStack {
                                    Text("\(viewModel.overdue.count)")
                                        .font(
                                            .system(.title2, design: .rounded)
                                        )
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    Text("Overdue")
                                        .font(
                                            .system(.caption, design: .rounded)
                                        )
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(viewModel.dueToday.count)")
                                        .font(
                                            .system(.title2, design: .rounded)
                                        )
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    Text("Today")
                                        .font(
                                            .system(.caption, design: .rounded)
                                        )
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(viewModel.upcoming.count)")
                                        .font(
                                            .system(.title2, design: .rounded)
                                        )
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                    Text("Upcoming")
                                        .font(
                                            .system(.caption, design: .rounded)
                                        )
                                        .foregroundColor(.secondary)
                                }
                                
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        
                        // Overdue section
                if !viewModel.overdue.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(
                                        systemName: "exclamationmark.triangle.fill"
                                    )
                                    .foregroundColor(.red)
                                    Text("Overdue")
                                        .font(
                                            .system(.headline, design: .rounded)
                                        )
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                }
                                .padding(.horizontal, 20)
                                
                        ForEach(viewModel.overdue) { task in
                                    TaskRow(task: task) {
                                        viewModel.toggleComplete(task)
                                    }
                                    .padding(.horizontal, 20)
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                                .swipeActions {
                                        Button(role: .destructive) { viewModel.delete(task: task) } label: { 
                                            Label("Delete", systemImage: "trash.fill") 
                                        }
                                        Button { editingTask = task } label: { 
                                            Label("Edit", systemImage: "pencil") 
                                        }
                                    }
                                    .contextMenu {
                                        Button(
                                            action: { selectedTask = task
                                            }) {
                                                Label(
                                                    "View Details",
                                                    systemImage: "eye"
                                                )
                                            }
                                        Button(action: { editingTask = task }) {
                                            Label(
                                                "Edit Task",
                                                systemImage: "pencil"
                                            )
                                        }
                                        Button(
                                            role: .destructive,
                                            action: { viewModel.delete(
                                                task: task
                                            )
                                            }) {
                                                Label(
                                                    "Delete Task",
                                                    systemImage: "trash"
                                                )
                                            }
                                    }
                                }
                            }
                        }

                        // Today section
                        if !viewModel.dueToday.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.blue)
                                    Text("Due Today")
                                        .font(
                                            .system(.headline, design: .rounded)
                                        )
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 20)
                                
                    ForEach(viewModel.dueToday) { task in
                                    TaskRow(task: task) {
                                        viewModel.toggleComplete(task)
                                    }
                                    .padding(.horizontal, 20)
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                            .swipeActions {
                                        Button(role: .destructive) { viewModel.delete(task: task) } label: { 
                                            Label("Delete", systemImage: "trash.fill") 
                                        }
                                        Button { editingTask = task } label: { 
                                            Label("Edit", systemImage: "pencil") 
                                        }
                                    }
                                    .contextMenu {
                                        Button(
                                            action: { selectedTask = task
                                            }) {
                                                Label(
                                                    "View Details",
                                                    systemImage: "eye"
                                                )
                                            }
                                        Button(action: { editingTask = task }) {
                                            Label(
                                                "Edit Task",
                                                systemImage: "pencil"
                                            )
                                        }
                                        Button(
                                            role: .destructive,
                                            action: { viewModel.delete(
                                                task: task
                                            )
                                            }) {
                                                Label(
                                                    "Delete Task",
                                                    systemImage: "trash"
                                                )
                                            }
                                    }
                                }
                            }
                        }

                        // Upcoming section
                        if !viewModel.upcoming.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.green)
                                    Text("Upcoming")
                                        .font(
                                            .system(.headline, design: .rounded)
                                        )
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 20)
                                
                    ForEach(viewModel.upcoming) { task in
                                    TaskRow(task: task) {
                                        viewModel.toggleComplete(task)
                                    }
                                    .padding(.horizontal, 20)
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                            .swipeActions {
                                        Button(role: .destructive) { viewModel.delete(task: task) } label: { 
                                            Label("Delete", systemImage: "trash.fill") 
                                        }
                                        Button { editingTask = task } label: { 
                                            Label("Edit", systemImage: "pencil") 
                                        }
                                    }
                                    .contextMenu {
                                        Button(
                                            action: { selectedTask = task
                                            }) {
                                                Label(
                                                    "View Details",
                                                    systemImage: "eye"
                                                )
                                            }
                                        Button(action: { editingTask = task }) {
                                            Label(
                                                "Edit Task",
                                                systemImage: "pencil"
                                            )
                                        }
                                        Button(
                                            role: .destructive,
                                            action: { viewModel.delete(
                                                task: task
                                            )
                                            }) {
                                                Label(
                                                    "Delete Task",
                                                    systemImage: "trash"
                                                )
                                            }
                                    }
                                }
                            }
                        }
                        
                        // Empty state
                        if viewModel.tasks.isEmpty {
                            VStack(spacing: 32) {
                                ZStack {
                                    Circle()
                                        .fill(
LinearGradient(
    colors: [
        Color.blue.opacity(0.1),
        Color.purple.opacity(0.1)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
                                        )
                                        .frame(width: 200, height: 200)
                                        .blur(radius: 20)
                                    
                                    VStack(spacing: 20) {
                                        Image(systemName: "book.closed.fill")
                                            .font(
                                                .system(
                                                    size: 80,
                                                    weight: .light
                                                )
                                            )
                                            .foregroundColor(.blue)
                                        
                                        Image(systemName: "sparkles")
                                            .font(
                                                .system(
                                                    size: 30,
                                                    weight: .medium
                                                )
                                            )
                                            .foregroundColor(.yellow)
                                            .offset(x: 30, y: -20)
                                    }
                                }
                                
                                // Content
                                VStack(spacing: 16) {
                                    Text("Ready to get organized?")
                                        .font(.system(.title, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(
                                        "Start by adding your first study task"
                                    )
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    
                                    // Quick tips
                                    VStack(spacing: 12) {
                                        Text("💡 Quick tips:")
                                            .font(
                                                .system(
                                                    .headline,
                                                    design: .rounded
                                                )
                                            )
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        VStack(
                                            alignment: .leading,
                                            spacing: 8
                                        ) {
                                            TipRow(
                                                icon: "calendar.badge.clock",
                                                text: "Add assignments with due dates"
                                            )
                                            TipRow(
                                                icon: "book.fill",
                                                text: "Organize reading materials"
                                            )
                                            TipRow(
                                                icon: "paintbrush.fill",
                                                text: "Color-code by subject"
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.gray.opacity(0.05))
                                    )
                                }
                                
                                // Call to action
                                VStack(spacing: 12) {
                                    Button(action: { showingAdd = true }) {
                                        HStack(spacing: 12) {
                                            Image(
                                                systemName: "plus.circle.fill"
                                            )
                                            .font(
                                                .system(size: 20, weight: .bold)
                                            )
                                            Text("Add Your First Task")
                                                .font(
                                                    .system(
                                                        .headline,
                                                        design: .rounded
                                                    )
                                                )
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 25)
                                        )
                                        .shadow(
                                            color: .blue.opacity(0.3),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    }
                                    
                                    Button(action: { addSampleTasks() }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "sparkles")
                                                .font(
                                                    .system(
                                                        size: 16,
                                                        weight: .medium
                                                    )
                                                )
                                            Text("Try Sample Tasks")
                                                .font(
                                                    .system(
                                                        .body,
                                                        design: .rounded
                                                    )
                                                )
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    Color.blue.opacity(0.3),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                    
                                    Text("or tap the + button below")
                                        .font(
                                            .system(.caption, design: .rounded)
                                        )
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 40)
                        }
                        
                        // Bottom padding
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 12) {
                    // Clear All Tasks button (only show when there are tasks)
                    if !viewModel.tasks.isEmpty {
                        Button(action: { 
                            showingClearAllAlert = true 
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Clear All")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.red)
                            )
                            .shadow(
                                color: .red.opacity(0.3),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                        }
                        .accessibilityLabel("Clear All Tasks")
                    }
                    
                    // Add Task button
                    Button(action: { showingAdd = true }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 56, height: 56)
                                .shadow(
                                    color: .blue.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                        .accessibilityLabel("Add Task")
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $showingAdd) {
                AddTaskView { newTask in
                    viewModel.add(newTask)
                }
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task) { updated in
                    viewModel.update(updated)
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(
                    task: task,
                    onEdit: { updatedTask in
                        viewModel.update(updatedTask)
                    },
                    onDelete: { taskToDelete in
                        viewModel.delete(task: taskToDelete)
                    },
                    onToggleComplete: { taskToToggle in
                        viewModel.toggleComplete(taskToToggle)
                    }
                )
            }
            .alert("Error", isPresented: .constant(viewModel.lastErrorMessage != nil), actions: {
                Button("Dismiss", role: .cancel) { viewModel.lastErrorMessage = nil }
                Button("Retry") { viewModel.reload() }
            }, message: {
                Text(viewModel.lastErrorMessage ?? "")
            })
            .alert("Clear All Tasks", isPresented: $showingClearAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllTasks()
                }
            } message: {
                Text(
                    "Are you sure you want to clear all tasks? This action cannot be undone."
                )
            }
        }
    }
}

// MARK: - Add View

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var subject: String = "IT"
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var priority: Priority = .medium
    @State private var currentStep: Int = 1

    var onSave: (TaskBase) -> Void

    private let subjects = ["IT", "Math", "History", "Design"]
    
    private var subjectColor: Color {
        switch subject.lowercased() {
        case "it": return .blue
        case "math": return .purple
        case "history": return .orange
        case "design": return .pink
        default: return .gray
        }
    }
    
    private var canProceedToStep2: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var canSave: Bool {
        canProceedToStep2 && dueDate >= Date()
    }
    
    private var titleError: String? {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Title cannot be empty." : nil
    }
    
    private var dueDateError: String? {
        dueDate < Date() ? "Due date cannot be in the past." : nil
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
                
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack {
                        ForEach(1...2, id: \.self) { step in
                            Circle()
                                .fill(
                                    step <= currentStep ? subjectColor : Color.gray
                                        .opacity(0.3)
                                )
                                .frame(width: 12, height: 12)
                            
                            if step < 2 {
                                Rectangle()
                                    .fill(
                                        step < currentStep ? subjectColor : Color.gray
                                            .opacity(0.3)
                                    )
                                    .frame(height: 2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 8) {
                                Image(
                                    systemName: currentStep == 1 ? "plus.circle.fill" : "calendar.circle.fill"
                                )
                                .font(.system(size: 50))
                                .foregroundColor(subjectColor)
                                
                                Text(
                                    currentStep == 1 ? "Basic Info" : "Schedule & Details"
                                )
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                
                                Text(
                                    currentStep == 1 ? "What do you need to do?" : "When and how important is it?"
                                )
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                            }
                            .padding(.top, 20)
                            
                            if currentStep == 1 {
                                // Step 1: Basic Info
                                VStack(spacing: 20) {
                                    // Title field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Task Title")
                                            .font(
                                                .system(
                                                    .headline,
                                                    design: .rounded
                                                )
                                            )
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        TextField(
                                            "Enter task title",
                                            text: $title
                                        )
                                        .textFieldStyle(StudentTextFieldStyle())
                                        if let err = titleError {
                                            Text(err)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.red)
                                        }
                                    }
                                    
                                    // Subject picker
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Subject")
                                            .font(
                                                .system(
                                                    .headline,
                                                    design: .rounded
                                                )
                                            )
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ], spacing: 12) {
                                            ForEach(
                                                subjects,
                                                id: \.self
                                            ) { subj in
                                                Button(
                                                    action: { subject = subj
                                                    }) {
                                                        HStack(spacing: 6) {
                                                            Circle()
                                                                .fill(
                                                                    subject == subj ? subjectColor : Color.gray
                                                                        .opacity(
                                                                            0.3
                                                                        )
                                                                )
                                                                .frame(
                                                                    width: 8,
                                                                    height: 8
                                                                )
                                                            Text(subj)
                                                                .font(
                                                                    .system(
                                                                        .body,
                                                                        design: .rounded
                                                                    )
                                                                )
                                                                .fontWeight(
                                                                    .medium
                                                                )
                                                                .lineLimit(1)
                                                                .minimumScaleFactor(
                                                                    0.8
                                                                )
                                                        }
                                                        .padding(
                                                            .horizontal,
                                                            12
                                                        )
                                                        .padding(.vertical, 10)
                                                        .frame(
                                                            maxWidth: .infinity
                                                        )
                                                        .background(
                                                            RoundedRectangle(
                                                                cornerRadius: 20
                                                            )
                                                            .fill(
                                                                subject == subj ? subjectColor
                                                                    .opacity(
                                                                        0.15
                                                                    ) : Color.gray
                                                                    .opacity(
                                                                        0.1
                                                                    )
                                                            )
                                                        )
                                                        .overlay(
                                                            RoundedRectangle(
                                                                cornerRadius: 20
                                                            )
                                                            .stroke(
                                                                subject == subj ? subjectColor : Color.clear,
                                                                lineWidth: 2
                                                            )
                                                        )
                                                    }
                                                    .foregroundColor(
                                                        subject == subj ? subjectColor : .primary
                                                    )
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                // Step 2: Schedule & Details
                                VStack(spacing: 20) {
                                    // Due date
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Due Date")
                                            .font(
                                                .system(
                                                    .headline,
                                                    design: .rounded
                                                )
                                            )
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        DatePicker(
                                            "",
                                            selection: $dueDate,
                                            displayedComponents: [
                                                .date,
                                                .hourAndMinute
                                            ]
                                        )
                                        .datePickerStyle(.compact)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )
                                        if let err = dueDateError {
                                            Text(err)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.red)
                                        }
                                    }
                                    
                                    // Priority picker
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Priority")
                                            .font(
                                                .system(
                                                    .headline,
                                                    design: .rounded
                                                )
                                            )
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        HStack(spacing: 12) {
                                            ForEach(
                                                Priority.allCases,
                                                id: \.self
                                            ) { prio in
                                                Button(
                                                    action: { priority = prio
                                                    }) {
                                                        HStack(spacing: 6) {
                                                            Circle()
                                                                .fill(
                                                                    priority == prio ? priorityColor(
                                                                        prio
                                                                    ) : Color.gray
                                                                        .opacity(
                                                                            0.3
                                                                        )
                                                                )
                                                                .frame(
                                                                    width: 8,
                                                                    height: 8
                                                                )
                                                            Text(
                                                                String(
                                                                    describing: prio
                                                                ).capitalized
                                                            )
                                                            .font(
                                                                .system(
                                                                    .body,
                                                                    design: .rounded
                                                                )
                                                            )
                                                            .fontWeight(.medium)
                                                        }
                                                        .padding(
                                                            .horizontal,
                                                            16
                                                        )
                                                        .padding(.vertical, 10)
                                                        .background(
                                                            RoundedRectangle(
                                                                cornerRadius: 20
                                                            )
                                                            .fill(
                                                                priority == prio ? priorityColor(
                                                                    prio
                                                                )
                                                                .opacity(
                                                                    0.15
                                                                ) : Color.gray
                                                                    .opacity(
                                                                        0.1
                                                                    )
                                                            )
                                                        )
                                                        .overlay(
                                                            RoundedRectangle(
                                                                cornerRadius: 20
                                                            )
                                                            .stroke(
                                                                priority == prio ? priorityColor(
                                                                    prio
                                                                ) : Color.clear,
                                                                lineWidth: 2
                                                            )
                                                        )
                                                    }
                                                    .foregroundColor(
                                                        priority == prio ? priorityColor(
                                                            prio
                                                        ) : .primary
                                                    )
                                            }
                                        }
                                    }
                                    
                                    // Notes field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Notes (Optional)")
                                            .font(
                                                .system(
                                                    .headline,
                                                    design: .rounded
                                                )
                                            )
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        TextField(
                                            "Add any additional notes",
                                            text: $details,
                                            axis: .vertical
                                        )
                                        .textFieldStyle(StudentTextFieldStyle())
                                        .lineLimit(3...6)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Bottom padding
                            Spacer(minLength: 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button("Cancel") { dismiss() }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: 16) {
                    if currentStep > 1 {
                        Button(action: { 
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                    }
                    
                    if currentStep < 2 {
                        Button(action: { 
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        subjectColor,
                                        subjectColor.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(
                                color: subjectColor.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                        .disabled(!canProceedToStep2)
                        .opacity(canProceedToStep2 ? 1 : 0.6)
                    } else {
                        Button(
action: {
    let task = AssignmentTask(
        title: title,
        details: details,
        subject: subject,
        dueDate: dueDate,
        priority: priority
    )
                        onSave(task)
                        dismiss()
}) {
    HStack {
        Image(systemName: "plus")
        Text("Add Task")
    }
    .font(.system(.headline, design: .rounded))
    .fontWeight(.semibold)
    .foregroundColor(.white)
    .padding(.horizontal, 32)
    .padding(.vertical, 16)
    .background(
        LinearGradient(
            colors: [subjectColor, subjectColor.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .clipShape(RoundedRectangle(cornerRadius: 25))
    .shadow(color: subjectColor.opacity(0.3), radius: 8, x: 0, y: 4)
}
.disabled(!canSave)
.opacity(canSave ? 1 : 0.6)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

// MARK: - Custom Text Field Style

struct StudentTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Tip Row Component

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Edit View

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var task: TaskBase
    @State private var title: String
    @State private var details: String
    @State private var subject: String
    @State private var dueDate: Date
    @State private var priority: Priority

    var onSave: (TaskBase) -> Void

    init(task: TaskBase, onSave: @escaping (TaskBase) -> Void) {
        self.task = task
        _title = State(initialValue: task.title)
        _details = State(initialValue: task.details)
        _subject = State(initialValue: task.subject)
        _dueDate = State(initialValue: task.dueDate)
        _priority = State(initialValue: task.priority)
        self.onSave = onSave
    }

    private let subjects = ["IT", "Math", "History", "Design"]
    
    private var subjectColor: Color {
        switch subject.lowercased() {
        case "it": return .blue
        case "math": return .purple
        case "history": return .orange
        case "design": return .pink
        default: return .gray
        }
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
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(subjectColor)
                            
                            Text("Edit Task")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Update your task details")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Title field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Task Title")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter task title", text: $title)
                                    .textFieldStyle(StudentTextFieldStyle())
                            }
                            
                            // Subject picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subject")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(subjects, id: \.self) { subj in
                                        Button(action: { subject = subj }) {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(
                                                        subject == subj ? subjectColor : Color.gray
                                                            .opacity(0.3)
                                                    )
                                                    .frame(width: 8, height: 8)
                                                Text(subj)
                                                    .font(
                                                        .system(
                                                            .body,
                                                            design: .rounded
                                                        )
                                                    )
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(
                                                    cornerRadius: 20
                                                )
                                                .fill(
                                                    subject == subj ? subjectColor
                                                        .opacity(
                                                            0.15
                                                        ) : Color.gray
                                                        .opacity(0.1)
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(
                                                    cornerRadius: 20
                                                )
                                                .stroke(
                                                    subject == subj ? subjectColor : Color.clear,
                                                    lineWidth: 2
                                                )
                                            )
                                        }
                                        .foregroundColor(
                                            subject == subj ? subjectColor : .primary
                                        )
                                    }
                                }
                            }
                            
                            // Due date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Due Date")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                DatePicker(
                                    "",
                                    selection: $dueDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Priority picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Priority")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 12) {
                                    ForEach(
                                        Priority.allCases,
                                        id: \.self
                                    ) { prio in
                                        Button(action: { priority = prio }) {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(
                                                        priority == prio ? priorityColor(
                                                            prio
                                                        ) : Color.gray
                                                            .opacity(0.3)
                                                    )
                                                    .frame(width: 8, height: 8)
                                                Text(
                                                    String(
                                                        describing: prio
                                                    ).capitalized
                                                )
                                                .font(
                                                    .system(
                                                        .body,
                                                        design: .rounded
                                                    )
                                                )
                                                .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(
                                                    cornerRadius: 20
                                                )
                                                .fill(
                                                    priority == prio ? priorityColor(
                                                        prio
                                                    )
                                                    .opacity(0.15) : Color.gray
                                                        .opacity(0.1)
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(
                                                    cornerRadius: 20
                                                )
                                                .stroke(
                                                    priority == prio ? priorityColor(
                                                        prio
                                                    ) : Color.clear,
                                                    lineWidth: 2
                                                )
                                            )
                                        }
                                        .foregroundColor(
                                            priority == prio ? priorityColor(
                                                prio
                                            ) : .primary
                                        )
                                    }
                                }
                            }
                            
                            // Notes field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes (Optional)")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField(
                                    "Add any additional notes",
                                    text: $details,
                                    axis: .vertical
                                )
                                .textFieldStyle(StudentTextFieldStyle())
                                .lineLimit(3...6)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Bottom padding
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button("Cancel") { dismiss() }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                    .padding(.trailing, 20)
            }
            .overlay(alignment: .bottom) {
                Button(action: {
                        task.title = title
                        task.details = details
                        task.subject = subject
                        task.dueDate = dueDate
                        task.priority = priority
                        onSave(task)
                        dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save Changes")
                    }
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [subjectColor, subjectColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(
                        color: subjectColor.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .disabled(
                    title
                        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || dueDate < Date()
                )
                .opacity(
                    title
                        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || dueDate < Date() ? 0.6 : 1
                )
                .padding(.bottom, 20)
            }
        }
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}


