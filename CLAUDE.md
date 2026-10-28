# MyHealthKit

SwiftUI iOS app (iPhone + iPad) using MVVM inside Clean Architecture.

## Build

Run from the repo root (the folder containing `MyHealthKit.xcodeproj`):

```bash
xcodebuild -scheme MyHealthKit -destination 'generic/platform=iOS Simulator' build -quiet
```

First-time setup: `cp Secrets.example.xcconfig MyHealthKit/Secrets.xcconfig` and fill in the
values — the build fails without that file.

The `MyHealthKit` folder is one synchronized folder group: new files are picked up automatically —
never edit `project.pbxproj` to add files. Xcode lists folders by name only, so ordering is done
with numeric prefixes.

## Project layout

- `MyHealthKit/App/` — app entry (`MyHealthKitApp.swift`) and root navigation (`App/Navigation/`).
- `MyHealthKit/Core/` — shared services behind protocols (location, image cache, chat client,
  logging, persistence helpers, design system). `Core/DI/AppContainer.swift` is the composition
  root: shared services + one container per feature.
- `MyHealthKit/Features/<Feature Name>/` — one folder per feature, layered:

```
<Feature Name>/
├── 1-Presentation/   Views/, ViewModels/ — SwiftUI + @Observable ViewModels
├── 2-Domain/         Entities/, UseCases/, Repositories/ (protocols), Services/ (protocols)
├── 3-Data/           Repositories/, Services/, DataSources/, Storage/, DTOs/, Endpoints/ — implementations
└── 4-DI/             <Feature>Container — wires the layers, builds ViewModels
```

Create only the subfolders a feature needs. Never add unprefixed layer folders or an `Application/` folder.
Reference features: `Medication Reminders/` (repository-backed), `EmergencySOS/` (service-backed).

## Architecture rules

- Dependency direction: `Presentation → Domain ← Data`. `4-DI/` is the only place that constructs
  `3-Data/` types; Presentation never references them.
- `2-Domain/` imports **Foundation only** — no SwiftUI, SwiftData, UIKit, PDFKit, Vision,
  UserNotifications, CoreLocation, Contacts, MessageUI, etc. Put platform work behind a protocol in
  `2-Domain/Services/` (or `Repositories/`) and implement it in `3-Data/Services/` (or `Repositories/`).
  Examples: `EmergencyCallerProtocol` → `UIKitEmergencyCaller`,
  `DocumentTextExtractorProtocol` → `VisionDocumentTextExtractor`.
- Use cases: `<Name>UseCaseProtocol` + `struct <Name>UseCaseImpl`, dependencies injected via `init`
  as `private let`, typed as protocols.
- One type per file, file named after the type (impl file drops the `Impl` suffix). Error enums get
  their own file in `2-Domain/Entities/`.
- ViewModels catch errors and expose user-friendly messages; don't let one action overwrite or
  clear another action's error.

## Networking

- HTTP goes through the NetworkKit package (`github.com/Liji-S/NetworkKit`), only from `3-Data/`.
  Never build `URLRequest`s or call `URLSession` directly in a data source.
- Each API call is an `Endpoint` in `3-Data/Endpoints/`; request/response types are DTOs in
  `3-Data/DTOs/`. Fixed headers (API keys, bundle ID) go in a `NetworkEnvironment` there too.
- Create one `NetworkClient` per server in `4-DI/` and inject it typed as `NetworkClientProtocol`.
- Mark DTOs and endpoints `nonisolated`: the target defaults to MainActor isolation, but NetworkKit
  encodes/decodes off the main actor.
- Read-only POSTs (searches) opt in to retries with
  `ExponentialBackoffRetryPolicy(retriesNonIdempotentRequests: true)`; never for writes.
- Keep `logLevel` at `.basic` or lower for anything carrying health data — `.body` prints payloads.
- Reference: Doctor Search (`GooglePlacesDataSourceImpl`).

## Concurrency

- Containers (`AppContainer`, feature containers) and `AppCoordinator` are `@MainActor`.
- If a Data implementation must run on the main actor (UIKit), mark the **protocol requirement**
  `@MainActor` too, not only the implementation. Don't put `@MainActor` on use case structs.

## Navigation

- Root navigation lives in `App/Navigation/`. `AppCoordinator` is the single owner of navigation
  state (`selectedTab`, `homePath`; the sidebar selection is derived). Open any top-level screen
  with `coordinator.open(_:)` — this is also the entry point for deep links, shortcuts and
  notification taps.
- `RouteViewFactory` is the only `AppRoute` → screen mapping, shared by the iPhone (TabView) and
  iPad (NavigationSplitView) layouts. A new top-level screen needs an `AppRoute` case, a factory
  branch and a case in `AppCoordinator.open(_:)`.
- Features never build other features' views; they report navigation through callbacks (like
  Dashboard's `onNavigate`). List → detail pushes and sheets within one feature stay in its views.
- Use cases and ViewModels never navigate.

## EmergencySOS is safety-critical

Any change to EmergencySOS must keep the emergency call working first:

- Nothing may run before the call or gate it. Secondary actions (share location, notify contacts,
  logging) run after or alongside it in a separate `Task`/`async let` whose failure can't affect the call.
- Never put other work in the same `do` block as `placeCallUseCase.execute`.
- Secondary actions need bounded duration (timeouts) and their own error message.
- Don't change the emergency number or the hold-to-call interaction as a side effect.

## Source control

GitHub Flow on `github.com/Liji-S/MyHealthKit`: `main` is always buildable; all work happens on
short-lived branches merged through pull requests.

- Never commit directly to `main`. Branch names: `feature/<short-name>`, `fix/<short-name>`,
  `refactor/<short-name>`, `chore/<short-name>`, `docs/<short-name>` (kebab-case).
- Commit messages follow Conventional Commits: `<type>(<scope>): <summary>` — types `feat`, `fix`,
  `refactor`, `chore`, `docs`, `test`; scope is the feature or area (`sos`, `medications`,
  `doctor-search`, `document-vault`, `first-aid`, `dashboard`, `nav`, `core`, `claude`). Summary in
  imperative mood, ≤ 72 chars; body explains *why* when it isn't obvious.
- One logical change per commit — don't mix a refactor with a feature, or unrelated features.
- The build must pass before committing.
- Never commit `MyHealthKit/Secrets.xcconfig`, `xcuserdata/`, `DerivedData/` or `.claude/settings.local.json`.
  Commit the shared scheme (`xcshareddata/`) and `Secrets.example.xcconfig` instead.
- Never force-push to `main` or rewrite pushed history. Don't push or open PRs unless asked.
- To branch, commit, push and open a PR, use the `ship` skill.

## Working conventions

- Don't touch unrelated features.
- Secrets come from `Secrets.xcconfig` via `AppConfig` — never hardcode keys.
- The test target (`MyHealthKitTests`) is still a template; when adding tests, test use cases with
  fake repositories/services.
- To add a use case to a feature, use the `add-use-case` skill.
