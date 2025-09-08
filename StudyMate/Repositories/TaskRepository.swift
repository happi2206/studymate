import Foundation

// Abstraction for loading and saving tasks.
public protocol TaskRepository {
    func load() throws -> [TaskBase]
    func save(_ tasks: [TaskBase]) throws
}


enum RepositoryError: Error {
    case documentsDirectoryUnavailable
}

// Codable wrapper that encodes/decodes heterogeneous arrays of `TaskBase`.
private struct TaskArrayCodable: Codable {
    let tasks: [TaskBase]

    init(tasks: [TaskBase]) { self.tasks = tasks }

    init(from decoder: Decoder) throws {
        self.tasks = try TaskPolymorphicCoder.decode(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try TaskPolymorphicCoder.encode(tasks, to: encoder)
    }
}

// File-backed implementation using JSON in the app's Documents directory.
public final class FileTaskRepository: TaskRepository {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL? = nil) throws {
        if let fileURL = fileURL {
            self.fileURL = fileURL
        } else {
            guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw RepositoryError.documentsDirectoryUnavailable
            }
            self.fileURL = documents.appendingPathComponent("tasks.json")
        }
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func load() throws -> [TaskBase] {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        if data.isEmpty { return [] }
        let wrapper = try decoder.decode(TaskArrayCodable.self, from: data)
        return wrapper.tasks
    }

    public func save(_ tasks: [TaskBase]) throws {
        let wrapper = TaskArrayCodable(tasks: tasks)
        let data = try encoder.encode(wrapper)
        try data.write(to: fileURL, options: [.atomic])
    }
 
}


