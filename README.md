# StudyTasks

A SwiftUI + MVVM sample app that helps students manage assignments, exams, and readings. It demonstrates Protocol-Oriented Programming (POP), OOP inheritance, repositories, persistence to JSON, validation, error handling, and unit tests.

## Link: 
https://github.com/happi2206/studymate

## Requirements
- iOS 17+
- SwiftUI
- No external dependencies

## Architecture
- Protocol layer (`Protocols/`):
  - `TaskIdentifiable`, `DeadlineTask` (default overdue logic), `Prioritizable`, `Priority` enum
- Models (`Models/`):
  - `TaskBase` (ObservableObject, Codable), subclasses: `AssignmentTask`, `ExamTask`, `ReadingTask`
  - Polymorphic Codable via `typeIdentifier` and `TaskPolymorphicCoder`
- Repository (`Repositories/`):
  - `TaskRepository` protocol
  - `FileTaskRepository` storing `tasks.json` in Documents, seeds sample data
- ViewModels (`ViewModels/`):
  - `TaskListViewModel` with sections: overdue, today, upcoming; add/update/delete; validation
- Views (`Views/`):
  - `TaskListView`, `TaskRow`, `AddTaskView`, `EditTaskView`
- Utilities (`Utilities/`):
  - `AppError`, `Validator.validate(_:)`

## Persistence
- Tasks are saved to `tasks.json` in the app's Documents directory using `JSONEncoder`/`JSONDecoder` with ISO8601 dates.
- On first launch (no file), the repository seeds a few sample tasks and subjects: IT, Math, History, Design.

## MVVM Flow
1. Views interact with `TaskListViewModel` (bind to `@Published` state, call actions).
2. ViewModel validates tasks and persists via `TaskRepository`.
3. Repository encodes/decodes via `TaskPolymorphicCoder` to preserve concrete subclasses.

## POP + OOP
- POP: Protocols declare capabilities (`TaskIdentifiable`, `DeadlineTask`, `Prioritizable`), with default overdue logic.
- OOP: `TaskBase` as a base class with shared behavior and subclass specializations for assignment/exam/reading.

## Running
- Open the Xcode project, select an iOS 17+ simulator, and build/run.
- The app launches `StudyTasksApp` which shows `TaskListView`.

## Tests
- Target: StudyTasksTests
- Includes:
  - Overdue logic
  - Validator (empty title, past due)
  - In-memory repository (save/load)
  - ViewModel (add saves, delete, upcoming sorting)

## Accessibility & UI
- **Welcome Splash Screen**: Animated intro with app features and personalized name input (persists via `UserDefaults`)
- **Student-Friendly Design**: Card-based layout, gradients, rounded typography
- **Subject Color Coding**: IT, Math, History, Design themed colors
- **Two-step Add Task**: Step 1 (Title, Subject), Step 2 (Due, Priority, Notes) with inline validation
- **Task Details**: Tapping a row opens a detailed view with notes and type-specific info
- **Actions**: Swipe actions + context menus for edit/delete; complete toggle
- **Empty State**: Engaging default empty state with tips and CTA; optional "Try Sample Tasks"
- **Floating Buttons**: Add (+) and Clear All (with confirmation)
- **Accessibility**: Dynamic Type-friendly; meaningful accessibility labels
- **Smooth Animations**: Transitions and micro-interactions throughout

## Features
- OOP + POP: `TaskBase` with `AssignmentTask`, `ExamTask`, `ReadingTask`; protocols `TaskIdentifiable`, `DeadlineTask`, `Prioritizable`
- MVVM: `TaskListViewModel` orchestrates validation, persistence, and derived collections
- Persistence: JSON file `tasks.json` in Documents via `FileTaskRepository` (no auto-seed on first launch)
- Error Handling: Validation errors (empty title, past due) + repository failures surfaced to UI; Retry supported
- Personalization: Name captured on first run and persisted to skip splash
- Optional Sample Data: Load sample tasks from the empty state button

## Design Decisions
- OOP + POP blend: Shared behavior in base class; capabilities defined by protocols for modularity and reuse
- MVVM rationale: Improves separation of concerns and testability
- Persistence choice: Lightweight JSON without external dependencies; easy to test and inspect
- Empty-first experience: Encourages onboarding; optional sample data for demos
- Accessibility: Labels and scalable typography

## Setup & Running
1. Open the Xcode project, iOS 17+.
2. Build and run. On first launch you’ll see the empty state.
3. Data path: `Documents/tasks.json` in the simulator/app sandbox.

## Tests
- Overdue logic
- Validator (empty title, past due)
- In-memory repository (save/load)
- ViewModel (add saves, delete, upcoming sorting)
- File repository returns empty on first launch (no auto-seed)
- `clearAllTasks()` persists empty array
- Two-step Add validation (cannot proceed/save when invalid)
- `UserDefaultsManager` name/onboarding persistence


