---
name: add-use-case
description: Scaffold a new use case in a MyHealthKit feature following the project's Clean Architecture conventions (Presentation / Domain / Data layers, protocol + Impl struct, repository or service injection, DI container wiring, ViewModel hookup). Use when the user asks to add a new use case, business action, or operation to a feature such as Medication Reminders, Doctor Search, Document Vault, EmergencySOS or First Aid.
argument-hint: <Feature Name> <UseCaseName> [short description]
---

# Add a Use Case to a MyHealthKit Feature

Arguments: $ARGUMENTS

Follow the architecture, concurrency and EmergencySOS rules in the repo's `CLAUDE.md`. This skill
is the procedure; paths below are relative to `MyHealthKit/Features/<Feature Name>/`.

## Steps

1. **Clarify** — If the feature name, use case name, or what it should do is missing from the
   arguments, ask the user before writing anything. Names are PascalCase verbs, e.g. `ArchiveMedication`.
   Also establish whether the use case needs **stored data** (repository), a **platform capability**
   (service), or both — this decides steps 5–6.

2. **Read before writing** — Read the feature's `4-DI/*Container.swift`, everything in
   `2-Domain/Repositories/` and `2-Domain/Services/` (whichever exist), one existing use case pair,
   and the ViewModel it will be hooked into, so the new code matches.

3. **Create the protocol** at `2-Domain/UseCases/<Name>UseCaseProtocol.swift`:

   ```swift
   import Foundation

   protocol <Name>UseCaseProtocol {
       func execute(<params>) async throws -> <Result>
   }
   ```

   New error types go in `2-Domain/Entities/<Feature>Error.swift` (or reuse an existing one).

4. **Create the implementation** at `2-Domain/UseCases/<Name>UseCase.swift`:

   ```swift
   import Foundation

   struct <Name>UseCaseImpl: <Name>UseCaseProtocol {
       private let repository: <Feature>RepositoryProtocol   // and/or: private let service: <X>Protocol

       init(repository: <Feature>RepositoryProtocol) {
           self.repository = repository
       }

       func execute(<params>) async throws -> <Result> {
           // business logic only
       }
   }
   ```

5. **Stored data (repository)** — only if needed:
   - Repository exists but lacks the method → add it to `2-Domain/Repositories/<Feature>RepositoryProtocol.swift`
     *and* `3-Data/Repositories/<Feature>RepositoryImpl.swift`.
   - Feature has **no repository** → bigger change (entity, repository protocol, impl + persistence).
     Tell the user what will be created and confirm before proceeding.

6. **Platform capability (service)** — only if needed: declare a minimal protocol in
   `2-Domain/Services/<Capability>Protocol.swift` and implement it in
   `3-Data/Services/<Framework><Capability>.swift`. Reuse an existing service protocol if one fits.

7. **Wire the DI container** — In `4-DI/<Feature>Container.swift`, add `private lazy var`s for any
   new repository/service (typed as the protocol) and for `<name>UseCase: <Name>UseCaseProtocol`,
   then pass the use case into the `make...ViewModel()` factory.

8. **Hook up the ViewModel** — Add a `private let` + `init` parameter, and a method that calls
   `execute`, catches errors, and shows a user-friendly message (use a separate error property if
   the ViewModel already reports errors for another action).

9. **Verify** — Run the build command from `CLAUDE.md` and fix any errors. If the test target has
   real tests, add one for the use case with a fake repository/service. Report the files
   created/changed.
