import Combine
import SwiftUI

struct EmergencySOSView: View {
    @State private var viewModel: EmergencySOSViewModel
    @State private var holdProgress: Double = 0
    @State private var isHolding = false

    // Scales the hold-button circle with Dynamic Type so the emergency
    // number inside it never gets clipped at larger accessibility sizes.
    @ScaledMetric(relativeTo: .largeTitle) private var buttonDiameter: CGFloat = 200

    private let holdDuration: Double = 2.0
    private let progressTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    init(viewModel: EmergencySOSViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Hold the button for 2 seconds to call \(viewModel.emergencyNumber)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(viewModel.emergencyNumber)
                    .font(.largeTitle.bold())
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
            }
            .frame(width: buttonDiameter, height: buttonDiameter)
            .contentShape(Circle())
            .scaleEffect(isHolding ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isHolding)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in startHold() }
                    .onEnded { _ in cancelHold() }
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Emergency SOS")
        .onReceive(progressTimer) { _ in
            guard isHolding, holdProgress < 1 else { return }
            holdProgress = min(holdProgress + 0.02 / holdDuration, 1)
            if holdProgress >= 1 {
                triggerCall()
            }
        }
    }

    private func startHold() {
        guard !isHolding else { return }
        isHolding = true
        impactGenerator.prepare()
        impactGenerator.impactOccurred(intensity: 0.5)
    }

    private func cancelHold() {
        isHolding = false
        holdProgress = 0
    }

    private func triggerCall() {
        isHolding = false
        holdProgress = 0
        notificationGenerator.notificationOccurred(.success)
        Task {
            await viewModel.call()
        }
    }
}
