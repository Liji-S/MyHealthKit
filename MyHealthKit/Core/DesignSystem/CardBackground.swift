import SwiftUI

private struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func cardBackground() -> some View {
        return modifier(CardBackground())
    }
}
