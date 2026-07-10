// ============================================================
// EffectDemos.swift — Swiftcn Showcase
// Live demos for the Effects category.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Aurora

struct AuroraDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack {
                SCAuroraBackground()
                SCCard {
                    Text("Ship faster").scH3()
                    Text("Soft ambient color, drifting behind your content.")
                        .scMuted()
                }
                .padding(32)
            }
            .frame(height: 280)
            ZStack {
                SCAuroraBackground(
                    colors: [.purple.opacity(0.3), .cyan.opacity(0.3), .pink.opacity(0.25)],
                    speed: 2,
                    blur: 48
                )
                Text("Custom colors").scH3()
            }
            .frame(height: 180)
        }
    }
}

// MARK: - Dot Pattern

struct DotPatternDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack {
                SCDotPattern()
                SCBadge("Hero section")
            }
            .frame(height: 180)
            ZStack {
                SCDotPattern(dotSize: 3, spacing: 20, fade: true)
                SCBadge("Faded edges", variant: .outline)
            }
            .frame(height: 180)
        }
    }
}

// MARK: - Marquee

struct MarqueeDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DemoSection("Leading · default speed") {
                SCMarquee {
                    HStack(spacing: 32) {
                        ForEach(
                            ["SwiftUI", "SwiftData", "Metal", "Combine", "WidgetKit", "TestFlight"],
                            id: \.self
                        ) { name in
                            SCBadge(name, variant: .secondary)
                        }
                    }
                }
            }
            DemoSection("Trailing · fast") {
                SCMarquee(speed: 80, direction: .trailing) {
                    HStack(spacing: 32) {
                        ForEach(["iOS", "iPadOS", "macOS", "watchOS", "visionOS"], id: \.self) {
                            SCBadge($0)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Number Ticker

struct NumberTickerDemo: View {
    @State private var value = 1024
    @State private var price = 128.75

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                SCNumberTicker(value: value)
                    .scH2()
                HStack(spacing: 8) {
                    Button {
                        value -= 125
                    } label: {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(.sc(.outline, size: .icon))
                    .accessibilityLabel("Decrease")
                    Button {
                        value += 125
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.sc(.outline, size: .icon))
                    .accessibilityLabel("Increase")
                }
            }
            DemoSection("Fractions") {
                VStack(alignment: .leading, spacing: 12) {
                    SCNumberTicker(value: price, format: .number.precision(.fractionLength(2)))
                        .scH3()
                    Button("Randomize") {
                        price = Double.random(in: 0...500)
                    }
                    .buttonStyle(.sc(.outline, size: .sm))
                }
            }
        }
    }
}

// MARK: - Shimmer

struct ShimmerDemo: View {
    @State private var active = true

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Introducing swiftcn 2.0")
                .font(.title2.weight(.semibold))
                .scShimmer()
            VStack(alignment: .leading, spacing: 12) {
                Button("Upgrade to Pro") {}
                    .buttonStyle(.sc())
                    .scShimmer(active: active, duration: 2.5)
                Button(active ? "Pause shimmer" : "Resume shimmer") {
                    active.toggle()
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }
        }
    }
}

// MARK: - Shimmer Button

struct ShimmerButtonDemo: View {
    var body: some View {
        SCShimmerButton(text: "Get Started") {}
    }
}
