import SwiftUI

// MARK: - Upgraded Prediction Insight Card
// A premium glassmorphic card with animated metrics and smooth transitions

struct PredictionInsightCard: View {
    let prediction: ActivityPrediction
    @State private var expanded = false
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Gradient Banner Header ──────────────────────────────
            bannerHeader
                .padding(.bottom, 16)

            Divider()
                .background(Color.white.opacity(0.15))
                .padding(.horizontal, 16)

            // ── Metric tiles ────────────────────────────────────────
            HStack(spacing: 10) {
                MetricTile(
                    icon: "flame.fill",
                    gradient: [Color(hex: "#FF6B35"), Color(hex: "#FF3D00")],
                    label: "Calories",
                    value: "\(prediction.recommendedCalories)",
                    unit: "kcal",
                    appeared: appeared
                )
                MetricTile(
                    icon: "figure.run",
                    gradient: [Color(hex: "#00C896"), Color(hex: "#00A3FF")],
                    label: "Activity",
                    value: String(format: "%.1f", prediction.recommendedActivityKM),
                    unit: "km",
                    appeared: appeared
                )
                MetricTile(
                    icon: "drop.fill",
                    gradient: [Color(hex: "#00B4FF"), Color(hex: "#0066FF")],
                    label: "Hydration",
                    value: prediction.recommendedWaterML > 0
                           ? String(format: "%.0f", prediction.recommendedWaterML)
                           : "—",
                    unit: prediction.recommendedWaterML > 0 ? "ml" : "",
                    appeared: appeared
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // ── Insights ────────────────────────────────────────────
            if !prediction.insights.isEmpty {
                Divider()
                    .padding(.horizontal, 16)

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        expanded.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption.bold())
                        Text(expanded ? "Hide insights" : "\(prediction.insights.count) AI insights")
                            .font(.caption.bold())
                        Spacer()
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#A78BFA"), Color(hex: "#60A5FA")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                if expanded {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(prediction.insights.enumerated()), id: \.offset) { idx, insight in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#A78BFA"), Color(hex: "#60A5FA")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 5)
                                Text(insight)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color(hex: "#7C3AED").opacity(0.12), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }

    // MARK: - Banner Header

    private var bannerHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient mesh background
            LinearGradient(
                colors: [Color(hex: "#1E1B4B"), Color(hex: "#312E81"), Color(hex: "#4C1D95")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(maxWidth: .infinity)
            .frame(height: 100)

            // Ambient blobs
            Circle()
                .fill(Color(hex: "#7C3AED").opacity(0.4))
                .frame(width: 80, height: 80)
                .blur(radius: 30)
                .offset(x: 30, y: 10)
            Circle()
                .fill(Color(hex: "#2563EB").opacity(0.3))
                .frame(width: 60, height: 60)
                .blur(radius: 25)
                .offset(x: 200, y: 5)

            // Content
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption.bold())
                            .foregroundColor(Color(hex: "#A78BFA"))
                        Text("PETORA AI · CORE ML")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "#A78BFA"))
                            .tracking(1.5)
                    }
                    Text("Tomorrow's Plan")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                Spacer()
                // Confidence badge
                VStack(spacing: 3) {
                    Image(systemName: prediction.confidenceLevel.icon)
                        .font(.caption2)
                    Text(prediction.confidenceLevel.rawValue)
                        .font(.system(size: 8, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(hex: prediction.confidenceLevel.color))
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(Color(hex: prediction.confidenceLevel.color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: prediction.confidenceLevel.color).opacity(0.3), lineWidth: 1))
            }
            .padding(16)
        }
    }

    // MARK: - Card Background

    @ViewBuilder
    private var cardBackground: some View {
        ZStack {
            Color(.systemBackground)
            LinearGradient(
                colors: [Color(hex: "#4C1D95").opacity(0.04), Color.clear],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Metric Tile

private struct MetricTile: View {
    let icon: String
    let gradient: [Color]
    let label: String
    let value: String
    let unit: String
    let appeared: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Gradient icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 42, height: 42)
                    .shadow(color: gradient.first?.opacity(0.35) ?? .clear, radius: 6, x: 0, y: 3)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(gradient.first ?? .secondary)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill((gradient.first ?? .gray).opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke((gradient.first ?? .gray).opacity(0.15), lineWidth: 1)
                )
        )
    }
}
