// ============================================================
// EffectDemos.swift — Swiftcn Showcase
// Live demos for the Effects category.
// ============================================================
import SwiftUI
import Swiftcn

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
