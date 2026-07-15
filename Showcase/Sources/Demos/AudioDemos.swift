// ============================================================
// AudioDemos.swift — Swiftcn macOS Showcase
// Live demos for the Audio category. All engines are simulated
// so the demos run without microphone permission.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Simulated engines

/// Deterministic level generator standing in for a microphone engine.
@MainActor
final class SimulatedAudioLevels: SCAudioLevelProvider {
    private let epoch = Date()

    func levels(bandCount: Int) -> [Float] {
        let time = Date().timeIntervalSince(epoch)
        return (0..<bandCount).map { band in
            let wave = sin(time * 3 + Double(band) * 0.6) * 0.35 + 0.45
            let ripple = sin(time * 7 + Double(band) * 1.7) * 0.15
            let noise = hashNoise(time.rounded(.down) * 78.233 + Double(band) * 12.9898) * 0.1
            return Float(max(0.05, min(1, wave + ripple + noise)))
        }
    }

    private func hashNoise(_ seed: Double) -> Double {
        let value = sin(seed) * 43758.5453123
        return value - value.rounded(.down)
    }
}

/// Scripted transcription session standing in for a realtime engine.
@MainActor @Observable
final class SimulatedSpeechSession: SCSpeechInputSession {
    private(set) var status = SCSpeechInputStatus.disconnected
    private(set) var partialTranscript = ""
    private(set) var committedTranscripts: [String] = []
    private(set) var error: String?

    private var feeder: Task<Void, Never>?

    func start() async throws {
        status = .connecting
        try await Task.sleep(for: .milliseconds(600))
        status = .connected
        feeder?.cancel()
        feeder = Task { [weak self] in
            let sentences = [
                "This demo streams a scripted transcript",
                "so it runs without microphone access",
            ]
            for sentence in sentences {
                var spoken: [String] = []
                for word in sentence.split(separator: " ") {
                    try? await Task.sleep(for: .milliseconds(240))
                    guard let self, !Task.isCancelled else { return }
                    spoken.append(String(word))
                    partialTranscript = spoken.joined(separator: " ")
                    status = .transcribing
                }
                guard let self, !Task.isCancelled else { return }
                committedTranscripts.append(partialTranscript + ".")
                partialTranscript = ""
            }
        }
    }

    func stop() {
        feeder?.cancel()
        status = .disconnected
    }

    func clearTranscripts() {
        partialTranscript = ""
        committedTranscripts = []
    }
}

/// Deterministic clock standing in for AVPlayer in the transcript demo.
@MainActor @Observable
final class SimulatedTranscriptPlayer: SCTranscriptViewerPlayer {
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval

    private var ticker: Task<Void, Never>?

    init(duration: TimeInterval) {
        self.duration = duration
    }

    func play() {
        guard !isPlaying else { return }
        if currentTime >= duration {
            currentTime = 0
        }
        isPlaying = true
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard let self, isPlaying, !Task.isCancelled else { return }
                currentTime = min(duration, currentTime + 0.05)
                if currentTime >= duration {
                    isPlaying = false
                    return
                }
            }
        }
    }

    func pause() {
        isPlaying = false
        ticker?.cancel()
    }

    func seek(to time: TimeInterval) {
        currentTime = min(max(time, 0), duration)
    }
}

// MARK: - Live Waveform

struct LiveWaveformDemo: View {
    @State private var active = false
    @State private var processing = false
    @State private var mode = SCLiveWaveformMode.static
    private let levels = SimulatedAudioLevels()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DemoSection("Simulated microphone · toggle the states") {
                SCCard {
                    SCLiveWaveform(
                        active: active,
                        processing: processing,
                        levels: levels,
                        barGap: 2,
                        height: 80,
                        historySize: 120,
                        mode: mode
                    )
                    WrappingRow {
                        Button(active ? "Stop Listening" : "Start Listening") {
                            active.toggle()
                            if active {
                                processing = false
                            }
                        }
                        .buttonStyle(.sc(active ? .default : .outline, size: .sm))
                        Button(processing ? "Stop Processing" : "Start Processing") {
                            processing.toggle()
                            if processing {
                                active = false
                            }
                        }
                        .buttonStyle(.sc(processing ? .default : .outline, size: .sm))
                        Button("Mode: \(mode == .static ? "Static" : "Scrolling")") {
                            mode = mode == .static ? .scrolling : .static
                        }
                        .buttonStyle(.sc(.outline, size: .sm))
                    }
                }
            }
            DemoSection("Idle baseline") {
                SCCard {
                    SCLiveWaveform()
                }
            }
        }
    }
}

// MARK: - Bar Visualizer

struct BarVisualizerDemo: View {
    @State private var state = SCAgentState.listening

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DemoSection("Demo mode · agent states") {
                VStack(alignment: .leading, spacing: 16) {
                    SCBarVisualizer(
                        state: state,
                        barCount: 20,
                        minHeight: 15,
                        maxHeight: 90,
                        demo: true,
                        height: 160
                    )
                    WrappingRow {
                        ForEach(SCAgentState.allCases, id: \.self) { candidate in
                            Button(candidate.rawValue.capitalized) {
                                state = candidate
                            }
                            .buttonStyle(.sc(state == candidate ? .default : .outline, size: .sm))
                        }
                    }
                }
            }
            DemoSection("Center aligned") {
                SCBarVisualizer(state: state, demo: true, centerAlign: true)
            }
        }
    }
}

// MARK: - Speech Input

struct SpeechInputDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DemoSection("Inside a textarea · simulated transcription") {
                SpeechInputTextareaExample()
            }
            DemoSection("Next to an input") {
                SpeechInputFieldExample()
            }
        }
    }
}

private struct SpeechInputTextareaExample: View {
    @State private var value = ""
    @State private var valueAtStart = ""
    private let session = SimulatedSpeechSession()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SCTextarea("Jot down some thoughts...", text: $value, minHeight: 120)
            SCSpeechInput(
                session: session,
                size: .sm,
                onChange: { value = merged($0.transcript) },
                onStart: { _ in valueAtStart = value },
                onStop: { value = merged($0.transcript) },
                onCancel: { _ in value = valueAtStart },
                content: {
                    SCSpeechInputCancelButton()
                    SCSpeechInputPreview()
                    SCSpeechInputRecordButton()
                }
            )
            .padding(10)
        }
    }

    private func merged(_ transcript: String) -> String {
        valueAtStart.isEmpty ? transcript : valueAtStart + " " + transcript
    }
}

private struct SpeechInputFieldExample: View {
    @State private var value = ""
    @State private var valueAtStart = ""
    private let session = SimulatedSpeechSession()

    var body: some View {
        HStack(spacing: 10) {
            SCInput("Give this idea a title...", text: $value)
            SCSpeechInput(
                session: session,
                onChange: { value = merged($0.transcript) },
                onStart: { _ in valueAtStart = value },
                onStop: { value = merged($0.transcript) },
                onCancel: { _ in value = valueAtStart },
                content: {
                    SCSpeechInputCancelButton()
                    SCSpeechInputRecordButton()
                }
            )
        }
    }

    private func merged(_ transcript: String) -> String {
        valueAtStart.isEmpty ? transcript : valueAtStart + " " + transcript
    }
}

// MARK: - Scrub Bar

struct ScrubBarDemo: View {
    @State private var value: TimeInterval = 42
    private let duration: TimeInterval = 156

    var body: some View {
        DemoSection("Compound playback control") {
            SCScrubBarContainer(
                duration: duration, value: value, onScrub: { value = $0 },
                content: {
                    SCScrubBarTimeLabel(time: value)
                        .frame(width: 44, alignment: .trailing)
                    SCScrubBarTrack {
                        SCScrubBarProgress()
                        SCScrubBarThumb()
                    }
                    .padding(.horizontal, 10)
                    SCScrubBarTimeLabel(time: duration)
                        .frame(width: 44, alignment: .leading)
                }
            )
            .font(.footnote)
        }
    }
}

// MARK: - Transcript Viewer

struct TranscriptViewerDemo: View {
    private let player = SimulatedTranscriptPlayer(duration: 8.5)
    private let alignment = Self.makeAlignment(
        "Every word follows the playback clock and the scrub bar seeks the same timeline."
    )

    var body: some View {
        DemoSection("Simulated narration") {
            SCTranscriptViewerContainer(player: player, alignment: alignment) {
                SCTranscriptViewerWords()
                HStack(spacing: 12) {
                    SCTranscriptViewerPlayPauseButton()
                    SCTranscriptViewerScrubBar()
                }
            }
        }
    }

    private static func makeAlignment(_ text: String) -> SCTranscriptAlignment {
        let characters = text.map(String.init)
        let starts = characters.indices.map { Double($0) * 0.1 }
        let ends = characters.indices.map { Double($0 + 1) * 0.1 }
        return SCTranscriptAlignment(
            characters: characters,
            characterStartTimesSeconds: starts,
            characterEndTimesSeconds: ends
        )
    }
}

// MARK: - Waveform

struct WaveformDemo: View {
    @State private var currentTime: TimeInterval = 28
    private let duration: TimeInterval = 96
    private let amplitudes = (0..<120).map {
        0.12 + abs(sin(Double($0) * 0.27)) * 0.72
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DemoSection("Recorded audio scrubber") {
                SCAudioScrubber(
                    data: amplitudes,
                    currentTime: currentTime,
                    duration: duration,
                    onSeek: { currentTime = $0 },
                    height: 96
                )
            }
            DemoSection("Static and scrolling") {
                VStack(spacing: 16) {
                    SCWaveform(data: amplitudes, height: 72)
                    SCScrollingWaveform(data: amplitudes, height: 72)
                }
            }
        }
    }
}
