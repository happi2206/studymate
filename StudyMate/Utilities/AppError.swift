import Foundation

// Domain errors used across the app.
public enum AppError: LocalizedError, Equatable {
    case emptyTitle
    case pastDueDate
    case saveFailed
    case loadFailed

    public var errorDescription: String? {
        switch self {
        case .emptyTitle: return "Title cannot be empty."
        case .pastDueDate: return "Due date cannot be in the past."
        case .saveFailed: return "Failed to save tasks."
        case .loadFailed: return "Failed to load tasks."
        }
    }
}

public enum Validator {
    /// Validates a task for basic constraints.
    public static func validate(_ task: TaskBase) throws {
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { throw AppError.emptyTitle }
        if task.dueDate < Date() { throw AppError.pastDueDate }
    }
}


