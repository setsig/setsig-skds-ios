import SwiftUI

public struct SetsigKioskView: View {
    public let client: SetsigClient
    public let venueID: String
    public let refreshIntervalSeconds: Int

    @State private var tokenData: KioskTokenResponse?
    @State private var secondsRemaining: Int
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var timer: Timer?

    public init(client: SetsigClient, venueID: String, refreshIntervalSeconds: Int = 60) {
        self.client = client
        self.venueID = venueID
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self._secondsRemaining = State(initialValue: refreshIntervalSeconds)
    }

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Circular Countdown Progress Ring
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: CGFloat(secondsRemaining) / CGFloat(refreshIntervalSeconds))
                    .stroke(secondsRemaining <= 10 ? Color.red : Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: secondsRemaining)

                // QR Body
                VStack {
                    if isLoading && tokenData == nil {
                        ProgressView()
                    } else if let error = errorMessage {
                        Text(error)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if let token = tokenData {
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .resizable()
                                .scaledToFit()
                                .padding(24)
                                .foregroundColor(.primary)

                            Text(String(token.tokenID.prefix(12)))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .padding(12)
            }
            .frame(width: 260, height: 260)

            // Seconds Tag
            Text("\(secondsRemaining)s")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(secondsRemaining <= 10 ? .red : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(UIColor.tertiarySystemBackground))
                .clipShape(Capsule())
        }
        .task {
            await fetchToken()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func fetchToken() async {
        isLoading = true
        errorMessage = nil
        do {
            let res = try await client.generateKioskToken(venueID: venueID, ttlSeconds: refreshIntervalSeconds)
            self.tokenData = res
            self.secondsRemaining = res.ttlRemaining
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if secondsRemaining <= 1 {
                Task {
                    await fetchToken()
                }
            } else {
                secondsRemaining -= 1
            }
        }
    }
}

