import AppKit
import ScreenCaptureKit

@main
struct CaptureApp {
    static func main() async throws {
        guard CommandLine.arguments.count == 4 else {
            fputs("usage: capture-app <process-id> <light|dark> <output.png>\n", stderr)
            exit(2)
        }

        guard let processID = pid_t(CommandLine.arguments[1]) else {
            fputs("capture-app: invalid process id\n", stderr)
            exit(2)
        }
        let appearance = CommandLine.arguments[2]
        let outputURL = URL(fileURLWithPath: CommandLine.arguments[3])

        for _ in 0..<75 {
            let content = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: true
            )

            if let application = content.applications.first(where: { $0.processID == processID }),
                let mainWindow = content.windows
                    .filter({ $0.owningApplication?.processID == application.processID })
                    .max(by: { windowArea($0) < windowArea($1) }),
                let display = content.displays.first(where: {
                    $0.frame.intersects(mainWindow.frame)
                })
            {
                let filter = SCContentFilter(
                    display: display,
                    including: [application],
                    exceptingWindows: []
                )
                let configuration = SCStreamConfiguration()
                let captureSize = CGSize(width: 900, height: 800)
                configuration.sourceRect = CGRect(
                    x: mainWindow.frame.midX - display.frame.minX - captureSize.width / 2,
                    y: mainWindow.frame.midY - display.frame.minY - captureSize.height / 2,
                    width: captureSize.width,
                    height: captureSize.height
                )
                configuration.width = Int(captureSize.width * 2)
                configuration.height = Int(captureSize.height * 2)
                configuration.captureResolution = .best
                configuration.showsCursor = false

                let image = try await SCScreenshotManager.captureImage(
                    contentFilter: filter,
                    configuration: configuration
                )
                let representation = try flattenedRepresentation(
                    image,
                    appearance: appearance
                )
                guard let png = representation.representation(using: .png, properties: [:]) else {
                    throw CaptureError.pngEncodingFailed
                }
                try png.write(to: outputURL)
                return
            }

            try await Task.sleep(for: .milliseconds(200))
        }

        throw CaptureError.applicationWindowNotFound(processID)
    }

    private static func windowArea(_ window: SCWindow) -> CGFloat {
        window.frame.width * window.frame.height
    }

    private static func flattenedRepresentation(
        _ image: CGImage,
        appearance: String
    ) throws -> NSBitmapImageRep {
        guard
            let representation = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: image.width,
                pixelsHigh: image.height,
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bitmapFormat: [],
                bytesPerRow: 0,
                bitsPerPixel: 0
            ),
            let context = NSGraphicsContext(bitmapImageRep: representation)
        else {
            throw CaptureError.bitmapCreationFailed
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        defer { NSGraphicsContext.restoreGraphicsState() }

        let bounds = NSRect(x: 0, y: 0, width: image.width, height: image.height)
        let background =
            appearance == "dark"
            ? NSColor(srgbRed: 0.035, green: 0.035, blue: 0.043, alpha: 1)
            : NSColor.white
        background.setFill()
        bounds.fill()
        NSImage(cgImage: image, size: bounds.size).draw(in: bounds)
        return representation
    }
}

private enum CaptureError: Error {
    case applicationWindowNotFound(pid_t)
    case bitmapCreationFailed
    case pngEncodingFailed
}
