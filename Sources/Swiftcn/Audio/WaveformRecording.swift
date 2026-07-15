// ============================================================
// WaveformRecording.swift — swiftcn-ui (Audio)
// Completed-take recording waveform for the waveform registry item.
// ============================================================
import SwiftUI

// MARK: - Recording waveform

/// A take recorder — elevenlabs-ui's `RecordingWaveform`. While
/// `recording`, averaged levels append to a growing take pinned to the
/// trailing edge; once stopped, the take is handed to
/// `onRecordingComplete` and becomes scrubbable with a position
/// indicator.
///
///     SCRecordingWaveform(
///         recording: isRecording,
///         levels: microphoneLevels,
///         onRecordingComplete: { take = $0 }
///     )
public struct SCRecordingWaveform: View {
    @Environment(\.theme) private var theme
    @State private var model = SCRecordingWaveformModel()
    @State private var viewPosition: Double = 1

    var recording: Bool
    var levels: (any SCAudioLevelProvider)?
    var sensitivity: Double
    var updateRate: TimeInterval
    var onRecordingComplete: (([Double]) -> Void)?
    var showHandle: Bool
    var barWidth: CGFloat
    var barHeight: CGFloat
    var barGap: CGFloat
    var barRadius: CGFloat
    var barColor: Color?
    var height: CGFloat?

    /// - Parameters:
    ///   - recording: Captures levels from `levels` while true.
    ///   - levels: The audio engine feeding normalized levels.
    ///   - sensitivity: Multiplier applied to sampled levels.
    ///   - updateRate: Seconds between samples (0.05 ≈ upstream's 50 ms).
    ///   - onRecordingComplete: Receives the finished take's amplitudes.
    ///   - showHandle: Shows the position indicator after recording.
    ///
    /// The remaining parameters match `SCWaveform`.
    public init(
        recording: Bool = false,
        levels: (any SCAudioLevelProvider)? = nil,
        sensitivity: Double = 1,
        updateRate: TimeInterval = 0.05,
        onRecordingComplete: (([Double]) -> Void)? = nil,
        showHandle: Bool = true,
        barWidth: CGFloat = 3,
        barHeight: CGFloat = 4,
        barGap: CGFloat = 1,
        barRadius: CGFloat = 1,
        barColor: Color? = nil,
        height: CGFloat? = 128
    ) {
        self.recording = recording
        self.levels = levels
        self.sensitivity = sensitivity
        self.updateRate = updateRate
        self.onRecordingComplete = onRecordingComplete
        self.showHandle = showHandle
        self.barWidth = barWidth
        self.barHeight = barHeight
        self.barGap = barGap
        self.barRadius = barRadius
        self.barColor = barColor
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            waveform(width: geometry.size.width)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .onChange(of: recording) { _, isRecording in
            recordingChanged(isRecording)
        }
    }

    private func waveform(width: CGFloat) -> some View {
        let scrubbable = !recording && model.isComplete
        return TimelineView(.animation) { timeline in
            Canvas { context, size in
                draw(in: &context, size: size, date: timeline.date)
            }
        }
        .contentShape(Rectangle())
        .gesture(scrubGesture(width: width), including: scrubbable ? .all : .none)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(scrubbable ? "Drag to scrub through recording" : "Recording waveform")
        .accessibilityValue(scrubbable ? "\(Int(viewPosition * 100)) percent" : "")
        .accessibilityAdjustableAction(adjust)
    }

    /// Upstream's recording lifecycle: reset on start, snapshot and
    /// report on stop.
    private func recordingChanged(_ isRecording: Bool) {
        if isRecording {
            model.isComplete = false
            model.recordingData = []
            model.recordedData = []
            viewPosition = 1
        } else if !model.recordingData.isEmpty {
            model.recordedData = model.recordingData
            model.isComplete = true
            onRecordingComplete?(model.recordingData)
        }
    }

    // MARK: Drawing

    private func draw(in context: inout GraphicsContext, size: CGSize, date: Date) {
        model.sampleIfDue(
            at: date,
            recording: recording,
            levels: levels,
            sensitivity: sensitivity,
            updateRate: updateRate
        )
        let renderer = SCWaveformRenderer(
            barWidth: barWidth,
            barHeight: barHeight,
            barGap: barGap,
            barRadius: barRadius,
            color: barColor ?? theme.foreground,
            heightScale: 0.7,
            fadeEdges: false,
            fadeWidth: 0
        )
        let data = recording ? model.recordingData : model.recordedData
        guard !data.isEmpty else { return }

        let step = barWidth + barGap
        let barsVisible = Int(size.width / step)
        var startIndex = 0
        if !recording && model.isComplete {
            if data.count > barsVisible {
                startIndex = Int(Double(data.count - barsVisible) * viewPosition)
            }
        } else if recording {
            startIndex = max(0, data.count - barsVisible)
        }

        var index = 0
        while index < barsVisible && startIndex + index < data.count {
            let value = data[startIndex + index]
            renderer.drawBar(
                value: value == 0 ? 0.1 : value,
                atX: CGFloat(index) * step,
                in: &context,
                size: size
            )
            index += 1
        }

        if !recording && model.isComplete && showHandle {
            drawIndicator(in: &context, size: size, color: renderer.color)
        }
    }

    /// Upstream's position indicator: a half-opacity line and a solid
    /// 6 pt-radius dot at the view position.
    private func drawIndicator(in context: inout GraphicsContext, size: CGSize, color: Color) {
        let indicatorX = size.width * viewPosition
        var line = Path()
        line.move(to: CGPoint(x: indicatorX, y: 0))
        line.addLine(to: CGPoint(x: indicatorX, y: size.height))
        context.stroke(line, with: .color(color.opacity(0.5)), lineWidth: 2)
        let dot = CGRect(x: indicatorX - 6, y: size.height / 2 - 6, width: 12, height: 12)
        context.fill(Path(ellipseIn: dot), with: .color(color))
    }

    // MARK: Scrubbing

    private func scrubGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                guard width > 0 else { return }
                viewPosition = min(max(gesture.location.x / width, 0), 1)
            }
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        guard !recording && model.isComplete else { return }
        let target = direction == .increment ? viewPosition + 0.05 : viewPosition - 0.05
        viewPosition = min(max(target, 0), 1)
    }
}

/// Reference-typed take buffers, mutated inside the `Canvas` renderer
/// the way upstream mutates its refs.
@MainActor
private final class SCRecordingWaveformModel {
    var recordingData: [Double] = []
    var recordedData: [Double] = []
    var isComplete = false
    private var lastSample = Date.distantPast

    func sampleIfDue(
        at date: Date,
        recording: Bool,
        levels: (any SCAudioLevelProvider)?,
        sensitivity: Double,
        updateRate: TimeInterval
    ) {
        guard recording, let levels, date.timeIntervalSince(lastSample) >= updateRate else { return }
        lastSample = date
        let average = Double(levels.levels(bandCount: 1).first ?? 0) * sensitivity
        recordingData.append(min(1, max(0.05, average)))
    }
}

// MARK: - Previews

/// Preview-only level generator so previews run without microphone access.
@MainActor
private final class SCWaveformPreviewLevels: SCAudioLevelProvider {
    private let epoch = Date()

    func levels(bandCount: Int) -> [Float] {
        let time = Date().timeIntervalSince(epoch)
        return (0..<bandCount).map { band in
            let wave = sin(time * 3 + Double(band) * 0.6) * 0.35 + 0.45
            let ripple = sin(time * 7 + Double(band) * 1.7) * 0.15
            return Float(max(0.05, min(1, wave + ripple)))
        }
    }
}

/// Preview-only scripted playback engine so previews run without audio.
@MainActor @Observable
private final class SCWaveformPreviewPlayback: SCWaveformRecordingPlayback {
    var duration: TimeInterval = 8
    private(set) var playbackPosition: TimeInterval?
    private var ticker: Task<Void, Never>?

    func playScrub(at time: TimeInterval, velocity: Double) {}

    func play(from time: TimeInterval) {
        ticker?.cancel()
        playbackPosition = time
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard let self, let position = playbackPosition, !Task.isCancelled else { return }
                let next = position + 0.05
                playbackPosition = next < duration ? next : nil
                if playbackPosition == nil { return }
            }
        }
    }

    func stop() {
        ticker?.cancel()
        playbackPosition = nil
    }
}

#Preview("MicrophoneWaveform") {
    @Previewable @State var active = true
    @Previewable @State var processing = false
    SCPreview {
        VStack(spacing: 20) {
            SCMicrophoneWaveform(
                active: active,
                processing: processing,
                levels: SCWaveformPreviewLevels(),
                height: 96
            )
            HStack(spacing: 8) {
                Button(active ? "Stop" : "Listen") {
                    active.toggle()
                    if active { processing = false }
                }
                .buttonStyle(.sc(.outline, size: .sm))
                Button(processing ? "Done" : "Process") {
                    processing.toggle()
                    if processing { active = false }
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }
        }
        .padding()
    }
}

#Preview("LiveMicrophoneWaveform") {
    @Previewable @State var active = false
    SCPreview {
        VStack(spacing: 20) {
            SCLiveMicrophoneWaveform(
                active: active,
                levels: SCWaveformPreviewLevels(),
                playback: SCWaveformPreviewPlayback(),
                height: 96
            )
            Button(active ? "Stop Recording" : "Record") {
                active.toggle()
            }
            .buttonStyle(.sc(active ? .default : .outline, size: .sm))
            Text("Stop, then drag the waveform to scrub.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("RecordingWaveform") {
    @Previewable @State var recording = false
    @Previewable @State var takeCount = 0
    SCPreview {
        VStack(spacing: 20) {
            SCRecordingWaveform(
                recording: recording,
                levels: SCWaveformPreviewLevels(),
                onRecordingComplete: { takeCount = $0.count },
                height: 96
            )
            Button(recording ? "Stop" : "Record") {
                recording.toggle()
            }
            .buttonStyle(.sc(recording ? .default : .outline, size: .sm))
            if takeCount > 0 {
                Text("Take captured: \(takeCount) samples")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
