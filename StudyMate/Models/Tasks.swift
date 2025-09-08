import Foundation
import Combine

open class TaskBase: ObservableObject, Identifiable, Codable, TaskIdentifiable, DeadlineTask, Prioritizable {
    public let id: UUID
    @Published public var title: String
    @Published public var details: String
    @Published public var subject: String
    @Published public var dueDate: Date
    @Published public var priority: Priority
    @Published public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        subject: String,
        dueDate: Date,
        priority: Priority = .medium,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.subject = subject
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
    }

    // Mark the task as complete.
    open func markComplete() {
        isCompleted = true
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case details
        case subject
        case dueDate
        case priority
        case isCompleted
        case typeIdentifier
    }

    open class var typeIdentifier: String { "TaskBase" }

    open class func makeEmptyInstance() -> TaskBase { TaskBase(title: "", subject: "", dueDate: .now) }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decode(String.self, forKey: .details)
        subject = try container.decode(String.self, forKey: .subject)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        priority = try container.decode(Priority.self, forKey: .priority)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(details, forKey: .details)
        try container.encode(subject, forKey: .subject)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(priority, forKey: .priority)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(Self.typeIdentifier, forKey: .typeIdentifier)
    }
}


public final class AssignmentTask: TaskBase {
    @Published public var submissionLink: URL?

    public init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        subject: String,
        dueDate: Date,
        priority: Priority = .medium,
        isCompleted: Bool = false,
        submissionLink: URL? = nil
    ) {
        self.submissionLink = submissionLink
        super.init(id: id, title: title, details: details, subject: subject, dueDate: dueDate, priority: priority, isCompleted: isCompleted)
    }

    // MARK: - Codable

    private enum ExtraKeys: String, CodingKey { case submissionLink }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ExtraKeys.self)
        submissionLink = try container.decodeIfPresent(URL.self, forKey: .submissionLink)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ExtraKeys.self)
        try container.encodeIfPresent(submissionLink, forKey: .submissionLink)
    }

    public override class var typeIdentifier: String { "AssignmentTask" }
}


public final class ExamTask: TaskBase {
    @Published public var location: String?

    public init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        subject: String,
        dueDate: Date,
        priority: Priority = .medium,
        isCompleted: Bool = false,
        location: String? = nil
    ) {
        self.location = location
        super.init(id: id, title: title, details: details, subject: subject, dueDate: dueDate, priority: priority, isCompleted: isCompleted)
    }

    // MARK: - Codable

    private enum ExtraKeys: String, CodingKey { case location }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ExtraKeys.self)
        location = try container.decodeIfPresent(String.self, forKey: .location)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ExtraKeys.self)
        try container.encodeIfPresent(location, forKey: .location)
    }

    public override class var typeIdentifier: String { "ExamTask" }
}


public final class ReadingTask: TaskBase {
    @Published public var chapterRange: String?

    public init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        subject: String,
        dueDate: Date,
        priority: Priority = .medium,
        isCompleted: Bool = false,
        chapterRange: String? = nil
    ) {
        self.chapterRange = chapterRange
        super.init(id: id, title: title, details: details, subject: subject, dueDate: dueDate, priority: priority, isCompleted: isCompleted)
    }

    // MARK: - Codable

    private enum ExtraKeys: String, CodingKey { case chapterRange }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ExtraKeys.self)
        chapterRange = try container.decodeIfPresent(String.self, forKey: .chapterRange)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ExtraKeys.self)
        try container.encodeIfPresent(chapterRange, forKey: .chapterRange)
    }

    public override class var typeIdentifier: String { "ReadingTask" }
}

// MARK: - Polymorphic Coding Support

/// A helper to decode arrays of TaskBase
public enum TaskPolymorphicCoder {
    private struct TypeKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { nil }
        init?(intValue: Int) { return nil }
    }

    // Encodes an array of tasks with type identifiers.
    public static func encode(_ tasks: [TaskBase], to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for task in tasks {
            let nested = container.superEncoder()
            try task.encode(to: nested)
        }
    }

    // Decodes an array of tasks by looking at each element's typeIdentifier key.
    public static func decode(from decoder: Decoder) throws -> [TaskBase] {
        var results: [TaskBase] = []
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let nested = try container.superDecoder()
            let keyed = try nested.container(keyedBy: TaskBase.CodingKeys.self)
            let typeId = try keyed.decode(String.self, forKey: TaskBase.CodingKeys.typeIdentifier)
            let task: TaskBase
            switch typeId {
            case AssignmentTask.typeIdentifier:
                task = try AssignmentTask(from: nested)
            case ExamTask.typeIdentifier:
                task = try ExamTask(from: nested)
            case ReadingTask.typeIdentifier:
                task = try ReadingTask(from: nested)
            default:
                task = try TaskBase(from: nested)
            }
            results.append(task)
        }
        return results
    }
}


