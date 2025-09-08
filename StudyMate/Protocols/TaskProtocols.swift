import Foundation

// Ensures every task can be uniquely identified.
public protocol TaskIdentifiable {
    var id: UUID { get }
}

// Represents supported priority levels for tasks.
public enum Priority: Int, Codable, CaseIterable {
    case low
    case medium
    case high
}

// Describes a task with a deadline and the ability to determine if it's overdue.
public protocol DeadlineTask {
    var dueDate: Date { get set }
    func isOverdue(now: Date) -> Bool
}

public extension DeadlineTask {
    func isOverdue(now: Date = .now) -> Bool {
        return dueDate < now
    }
}

// Adds prioritization to a type 
public protocol Prioritizable {
    var priority: Priority { get set }
}


