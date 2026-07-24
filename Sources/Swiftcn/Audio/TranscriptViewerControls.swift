// ============================================================
// TranscriptViewerControls.swift — swiftcn-ui (Audio)
// Play/pause and scrub-bar parts for the transcript-viewer
// registry item.
// ============================================================
import SwiftUI

// MARK: - Play/pause button

/// Toggles transcript playback — upstream's
/// `TranscriptViewerPlayPauseButton`. Shows play or pause icons by
/// default; a custom label builder receives the playing state.
///
///     SCTranscriptViewerPlayPauseButton()
///
///     SCTranscriptViewerPlayPauseButton(size: .default) { isPlaying in
///         Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill")
///     }
public struct SCTranscriptViewerPlayPauseButton<Label: View>: View {
    @Environment(\.scTranscriptViewer) private var transcriptViewer

    var variant: SCButtonVariant
    var size: SCButtonSize
    var action: (() -> Void)?
    var label: ((Bool) -> Label)?

    /// - Parameters:
    ///   - variant: Button variant (outline, as upstream).
    ///   - size: Button size (icon, as upstream).
    ///   - action: Extra handler invoked after toggling (`onClick`).
    ///   - label: Custom label receiving the playing state.
    public init(
        variant: SCButtonVariant = .outline,
        size: SCButtonSize = .icon,
        action: (() -> Void)? = nil,
        @ViewBuilder label: @escaping (Bool) -> Label
    ) {
        self.variant = variant
        self.size = size
        self.action = action
        self.label = label
    }

    public var body: some View {
        if let context = transcriptViewer {
            button(context)
        }
    }

    private func button(_ context: SCTranscriptViewerContext) -> some View {
        Button {
            if context.isPlaying {
                context.pause()
            } else {
                context.play()
            }
            action?()
        } label: {
            if let label {
                label(context.isPlaying)
            } else {
                Image(systemName: context.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .buttonStyle(.sc(variant, size: size))
        .accessibilityLabel(context.isPlaying ? "Pause audio" : "Play audio")
    }
}

extension SCTranscriptViewerPlayPauseButton where Label == EmptyView {
    /// The default play/pause icon button.
    public init(
        variant: SCButtonVariant = .outline,
        size: SCButtonSize = .icon,
        action: (() -> Void)? = nil
    ) {
        self.variant = variant
        self.size = size
        self.action = action
        self.label = nil
    }
}

// MARK: - Scrub bar

/// The context-aware scrub bar — upstream's `TranscriptViewerScrubBar`.
/// Wires the shared `SCScrubBar` parts to the transcript context, with
/// elapsed and remaining time labels underneath.
///
///     SCTranscriptViewerScrubBar()
public struct SCTranscriptViewerScrubBar: View {
    @Environment(\.scTranscriptViewer) private var transcriptViewer
    @Environment(\.theme) private var theme

    var showTimeLabels: Bool
    var trackTint: Color?
    var progressTint: Color?
    var thumbTint: Color?

    /// - Parameter showTimeLabels: Shows elapsed/remaining labels below
    ///   the track.
    public init(
        showTimeLabels: Bool = true,
        trackTint: Color? = nil,
        progressTint: Color? = nil,
        thumbTint: Color? = nil
    ) {
        self.showTimeLabels = showTimeLabels
        self.trackTint = trackTint
        self.progressTint = progressTint
        self.thumbTint = thumbTint
    }

    public var body: some View {
        if let context = transcriptViewer {
            scrubBar(context)
        }
    }

    private func scrubBar(_ context: SCTranscriptViewerContext) -> some View {
        SCScrubBarContainer(
            duration: context.duration,
            value: context.currentTime,
            onScrub: context.seekToTime,
            onScrubStart: context.startScrubbing,
            onScrubEnd: context.endScrubbing
        ) {
            VStack(spacing: 4) {
                SCScrubBarTrack {
                    SCScrubBarProgress(trackTint: trackTint, progressTint: progressTint)
                    SCScrubBarThumb(tint: thumbTint)
                }
                if showTimeLabels {
                    HStack {
                        SCScrubBarTimeLabel(time: context.currentTime)
                        Spacer()
                        SCScrubBarTimeLabel(time: context.duration - context.currentTime)
                    }
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
                }
            }
        }
    }
}

// MARK: - Previews

/// Preview-only clock player so previews run without audio files.
@MainActor @Observable
private final class SCTranscriptViewerPreviewPlayer: SCTranscriptViewerPlayer {
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

/// Builds uniform character timing for a sentence, for previews only.
private func previewAlignment(_ text: String, duration: TimeInterval) -> SCTranscriptAlignment {
    let characters = text.map(String.init)
    let step = duration / Double(max(characters.count, 1))
    let starts = characters.indices.map { Double($0) * step }
    return SCTranscriptAlignment(
        characters: characters,
        characterStartTimesSeconds: starts,
        characterEndTimesSeconds: starts.map { $0 + step }
    )
}

#Preview("TranscriptViewer") {
    let duration: TimeInterval = 9
    let alignment = previewAlignment(
        "The transcript viewer highlights every word as the narration plays and lets you scrub to any moment.",
        duration: duration
    )
    SCPreview {
        SCTranscriptViewerContainer(
            player: SCTranscriptViewerPreviewPlayer(duration: duration),
            alignment: alignment
        ) {
            SCTranscriptViewerWords()
            SCTranscriptViewerScrubBar()
            SCTranscriptViewerPlayPauseButton()
        }
        .frame(maxWidth: 420)
    }
}

#Preview("TranscriptViewer · hidden audio tags") {
    let duration: TimeInterval = 6
    let alignment = previewAlignment(
        "Audio tags [laughs] disappear from the transcript [sighs] when hideAudioTags is on.",
        duration: duration
    )
    SCPreview {
        SCTranscriptViewerContainer(
            player: SCTranscriptViewerPreviewPlayer(duration: duration),
            alignment: alignment,
            hideAudioTags: true
        ) {
            SCTranscriptViewerWords()
            SCTranscriptViewerScrubBar(showTimeLabels: false)
            SCTranscriptViewerPlayPauseButton()
        }
        .frame(maxWidth: 420)
    }
}

#Preview("TranscriptViewer · custom words") {
    let duration: TimeInterval = 7
    let alignment = previewAlignment(
        "Custom word rendering keeps the same timing engine underneath.",
        duration: duration
    )
    SCPreview {
        SCTranscriptViewerContainer(
            player: SCTranscriptViewerPreviewPlayer(duration: duration),
            alignment: alignment
        ) {
            SCTranscriptViewerWords(renderWord: { word, status in
                Text(word.text)
                    .bold(status == .current)
                    .underline(status == .current)
                    .opacity(status == .unspoken ? 0.4 : 1)
            })
            SCTranscriptViewerScrubBar()
            SCTranscriptViewerPlayPauseButton(size: .default) { isPlaying in
                SwiftUI.Label(
                    isPlaying ? "Pause" : "Play",
                    systemImage: isPlaying ? "pause.fill" : "play.fill"
                )
            }
        }
        .frame(maxWidth: 420)
    }
}
