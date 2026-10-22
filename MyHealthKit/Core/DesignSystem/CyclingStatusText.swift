import SwiftUI

/// Rotates through a list of status phrases at a fixed interval, for
/// long-running async work where a single static label feels stalled.
///
/// Cycling restarts from the first phrase whenever this view is recreated
/// (e.g. give it a `.id()` tied to the work's start) rather than continuing
/// from wall-clock time, so repeated runs don't pick up mid-cycle.
struct CyclingStatusText: View {
    let phrases: [String]
    var interval: TimeInterval = 2.5

    @State private var startDate = Date()

    var body: some View {
        TimelineView(.periodic(from: startDate, by: interval)) { context in
            Text(phrase(at: context.date))
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: phrase(at: context.date))
        }
        .onAppear { startDate = Date() }
    }

    private func phrase(at date: Date) -> String {
        guard !phrases.isEmpty else { return "" }
        let elapsed = Int(date.timeIntervalSince(startDate) / interval)
        // Hold on the last phrase once reached, rather than wrapping back to
        // the first — work that runs longer than the phrase list shouldn't
        // look like it's starting over.
        let index = min(elapsed, phrases.count - 1)
        return phrases[index]
    }
}
