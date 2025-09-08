import XCTest
@testable import StudyMate

@MainActor
final class StudyTasksTests: XCTestCase {
    func testOverdueLogic() throws {
        let past = Date().addingTimeInterval(-3600)
        let task = AssignmentTask(title: "Past", subject: "IT", dueDate: past)
        XCTAssertTrue(task.isOverdue())
    }

    func testValidatorEmptyTitle() throws {
        let task = AssignmentTask(title: " ", subject: "IT", dueDate: Date().addingTimeInterval(3600))
        XCTAssertThrowsError(try Validator.validate(task)) { error in
            XCTAssertEqual(error as? AppError, .emptyTitle)
        }
    }

    func testValidatorPastDue() throws {
        let task = AssignmentTask(title: "A", subject: "IT", dueDate: Date().addingTimeInterval(-3600))
        XCTAssertThrowsError(try Validator.validate(task)) { error in
            XCTAssertEqual(error as? AppError, .pastDueDate)
        }
    }

    func testInMemoryRepoSaveLoad() throws {
        let repo = InMemoryRepo()
        let t1 = AssignmentTask(title: "T1", subject: "IT", dueDate: Date().addingTimeInterval(3600))
        try repo.save([t1])
        let loaded = try repo.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, t1.id)
    }

    func testAddSavesAndDelete() throws {
        let repo = InMemoryRepo()
        let vm = TaskListViewModel(repository: repo)
        let t1 = AssignmentTask(title: "T1", subject: "IT", dueDate: Date().addingTimeInterval(3600))
        vm.add(t1)
        XCTAssertEqual(repo.savedTasks.count, 1)
        vm.delete(task: t1)
        XCTAssertEqual(repo.savedTasks.count, 0)
    }

    func testSortingUpcoming() throws {
        let repo = InMemoryRepo()
        let now = Date()
        let t1 = AssignmentTask(title: "Low Later", subject: "IT", dueDate: now.addingTimeInterval(7200), priority: .low)
        let t2 = AssignmentTask(title: "High Sooner", subject: "IT", dueDate: now.addingTimeInterval(3600), priority: .high)
        try repo.save([t1, t2])
        let vm = TaskListViewModel(repository: repo)
        XCTAssertEqual(vm.upcoming.first?.id, t2.id)
    }
}

// MARK: - Test Doubles

final class InMemoryRepo: TaskRepository {
    var savedTasks: [TaskBase] = []
    func load() throws -> [TaskBase] { savedTasks }
    func save(_ tasks: [TaskBase]) throws { savedTasks = tasks }
}


@MainActor
final class RepositoryBehaviorTests: XCTestCase {
    func testFileRepoReturnsEmptyOnFirstLaunch() throws {
        // Create a temp file URL that does not exist
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("tasks.json")
        let repo = try FileTaskRepository(fileURL: fileURL)
        let loaded = try repo.load()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testClearAllTasksPersists() throws {
        let repo = InMemoryRepo()
        let vm = TaskListViewModel(repository: repo)
        let t1 = AssignmentTask(title: "T1", subject: "IT", dueDate: Date().addingTimeInterval(3600))
        vm.add(t1)
        XCTAssertEqual(repo.savedTasks.count, 1)
        vm.clearAllTasks()
        XCTAssertEqual(repo.savedTasks.count, 0)
        XCTAssertTrue(vm.tasks.isEmpty)
    }
}

@MainActor
final class ValidationFlowTests: XCTestCase {
    func testAddRejectsEmptyTitle() throws {
        let repo = InMemoryRepo()
        let vm = TaskListViewModel(repository: repo)
        let task = AssignmentTask(title: " ", subject: "IT", dueDate: Date().addingTimeInterval(3600))
        vm.add(task)
        XCTAssertTrue(repo.savedTasks.isEmpty)
        XCTAssertEqual(vm.lastErrorMessage, "Title cannot be empty.")
    }

    func testAddRejectsPastDue() throws {
        let repo = InMemoryRepo()
        let vm = TaskListViewModel(repository: repo)
        let task = AssignmentTask(title: "X", subject: "IT", dueDate: Date().addingTimeInterval(-3600))
        vm.add(task)
        XCTAssertTrue(repo.savedTasks.isEmpty)
        XCTAssertEqual(vm.lastErrorMessage, "Due date cannot be in the past.")
    }
}

final class UserDefaultsManagerTests: XCTestCase {
    func testNamePersistence() {
        let manager = UserDefaultsManager.shared
        let previousName = manager.userName
        manager.saveUserName("Tester")
        XCTAssertTrue(manager.hasCompletedOnboarding)
        XCTAssertEqual(manager.userName, "Tester")
        // restore
        manager.saveUserName(previousName)
    }
}



