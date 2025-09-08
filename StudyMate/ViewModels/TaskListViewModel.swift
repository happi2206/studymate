import Foundation

@MainActor
public final class TaskListViewModel: ObservableObject {
    @Published public private(set) var tasks: [TaskBase] = []
    @Published public var selectedSubject: String? = nil
    @Published public var lastErrorMessage: String? = nil

    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
        do {
            self.tasks = try repository.load().sorted(by: Self.sortByDueDate)
        } catch {
            self.tasks = []
            self.lastErrorMessage = "Failed to load tasks."
        }
    }



    public var overdue: [TaskBase] {
        tasks.filter { !$0.isCompleted && $0.isOverdue() }.sorted(by: Self.sortByDueDate)
    }

    public var dueToday: [TaskBase] {
        let cal = Calendar.current
        return tasks.filter { !$0.isCompleted && cal.isDateInToday($0.dueDate) && !$0.isOverdue() }
            .sorted(by: Self.sortByDueDate)
    }

    public var upcoming: [TaskBase] {
        let cal = Calendar.current
        return tasks.filter { !$0.isCompleted && !cal.isDateInToday($0.dueDate) && !$0.isOverdue() }
            .sorted(by: Self.sortByDueDate)
    }

    public var filteredBySubject: [TaskBase] {
        guard let subject = selectedSubject, !subject.isEmpty else { return tasks }
        return tasks.filter { $0.subject == subject }
    }

    // MARK: - CRUD

    public func add(_ task: TaskBase) {
        guard validate(task) else { return }
        tasks.append(task)
        tasks.sort(by: Self.sortByDueDate)
        persist()
    }

    public func update(_ task: TaskBase) {
        guard validate(task) else { return }
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
            tasks.sort(by: Self.sortByDueDate)
            persist()
        }
    }

    public func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        persist()
    }

    public func delete(task: TaskBase) {
        tasks.removeAll { $0.id == task.id }
        persist()
    }
    
    public func clearAllTasks() {
        tasks.removeAll()
        persist()
    }

    public func toggleComplete(_ task: TaskBase) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isCompleted.toggle()
        persist()
    }

    // MARK: - Validation

    private func validate(_ task: TaskBase) -> Bool {
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lastErrorMessage = "Title cannot be empty."
            return false
        }
        if task.dueDate < Date() {
            lastErrorMessage = "Due date cannot be in the past."
            return false
        }
        lastErrorMessage = nil
        return true
    }

    // MARK: - Persistence

    private func persist() {
        do { try repository.save(tasks) } catch { lastErrorMessage = "Failed to save tasks." }
    }

    private static func sortByDueDate(lhs: TaskBase, rhs: TaskBase) -> Bool {
        if lhs.dueDate == rhs.dueDate { return lhs.priority.rawValue > rhs.priority.rawValue }
        return lhs.dueDate < rhs.dueDate
    }

    // MARK: - Error Handling / Reload

    public func reload() {
        do {
            let loaded = try repository.load().sorted(by: Self.sortByDueDate)
            self.tasks = loaded
            self.lastErrorMessage = nil
        } catch {
            self.lastErrorMessage = "Failed to load tasks."
        }
    }
}


