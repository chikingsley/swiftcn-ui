import AppKit
import Foundation

private let fixtureNames = [
    "accordion-expanded-light",
    "accordion-expanded-dark",
    "accordion-collapsed-light",
    "accordion-collapsed-dark",
    "alert-default-light",
    "alert-default-dark",
    "alert-destructive-light",
    "alert-destructive-dark",
]

private struct Raster {
    let width: Int
    let height: Int
    let pixels: [UInt8]
}

@main
private enum PilotParityChecker {
    static func main() throws {
        guard CommandLine.arguments.count == 5 else {
            fputs(
                "usage: compare-pilot <swift-dir> <web-dir> <report.json> <diff-dir>\n",
                stderr
            )
            exit(2)
        }

        let swiftDirectory = URL(fileURLWithPath: CommandLine.arguments[1])
        let webDirectory = URL(fileURLWithPath: CommandLine.arguments[2])
        let reportURL = URL(fileURLWithPath: CommandLine.arguments[3])
        let diffDirectory = URL(fileURLWithPath: CommandLine.arguments[4])
        try FileManager.default.createDirectory(
            at: diffDirectory,
            withIntermediateDirectories: true
        )

        var reports: [[String: Any]] = []
        var failed = false

        for name in fixtureNames {
            let swiftImage = try loadImage(swiftDirectory.appending(path: "\(name).png"))
            let webImage = try loadImage(webDirectory.appending(path: "\(name).png"))
            let swiftRaster = rasterize(swiftImage, width: 256, height: 128)
            let webRaster = rasterize(webImage, width: 256, height: 128)

            let perceptual = perceptualSimilarity(swiftRaster, webRaster)
            let edge = edgeSimilarity(swiftRaster, webRaster)
            let ink = inkDice(swiftRaster, webRaster)
            let widthSimilarity = ratioSimilarity(
                Double(swiftImage.width),
                Double(webImage.width)
            )
            let aspectSimilarity = ratioSimilarity(
                Double(swiftImage.width) / Double(swiftImage.height),
                Double(webImage.width) / Double(webImage.height)
            )
            let overall =
                0.35 * perceptual
                + 0.25 * edge
                + 0.25 * ink
                + 0.15 * aspectSimilarity

            // Cross-runtime parity is intentionally not pixel equality. The
            // hard gates preserve the shared stage width and broad geometry;
            // the lower-resolution color/edge/ink score tolerates native font
            // and symbol rasterization while still catching missing states,
            // wrappers, borders, or substantially different compositions.
            let passes = widthSimilarity >= 0.99
                && aspectSimilarity >= 0.80
                && ink >= 0.35
                && overall >= 0.80
            failed = failed || !passes

            try writeDiff(
                swiftRaster,
                webRaster,
                to: diffDirectory.appending(path: "\(name)-diff.png")
            )

            let result: [String: Any] = [
                "fixture": name,
                "passes": passes,
                "swiftPixels": ["width": swiftImage.width, "height": swiftImage.height],
                "webPixels": ["width": webImage.width, "height": webImage.height],
                "widthSimilarity": rounded(widthSimilarity),
                "aspectSimilarity": rounded(aspectSimilarity),
                "perceptualSimilarity": rounded(perceptual),
                "edgeSimilarity": rounded(edge),
                "inkDice": rounded(ink),
                "overall": rounded(overall),
            ]
            reports.append(result)
            print(
                String(
                    format: "%@ %@ overall=%.3f perceptual=%.3f edge=%.3f ink=%.3f aspect=%.3f",
                    passes ? "PASS" : "FAIL",
                    name,
                    overall,
                    perceptual,
                    edge,
                    ink,
                    aspectSimilarity
                )
            )
        }

        let report: [String: Any] = [
            "schemaVersion": 1,
            "method": "normalized RGB, edge-map, ink-mask, and aspect comparison",
            "thresholds": [
                "widthSimilarity": 0.99,
                "aspectSimilarity": 0.80,
                "inkDice": 0.35,
                "overall": 0.80,
            ],
            "passed": !failed,
            "fixtures": reports,
        ]
        let data = try JSONSerialization.data(
            withJSONObject: report,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        try data.write(to: reportURL, options: .atomic)

        if failed { exit(1) }
    }

    private static func loadImage(_ url: URL) throws -> CGImage {
        guard
            let data = try? Data(contentsOf: url),
            let representation = NSBitmapImageRep(data: data),
            let image = representation.cgImage
        else {
            throw CheckerError.cannotReadImage(url.path)
        }
        return image
    }

    private static func rasterize(_ image: CGImage, width: Int, height: Int) -> Raster {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        pixels.withUnsafeMutableBytes { bytes in
            guard
                let context = CGContext(
                    data: bytes.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            else { return }
            context.interpolationQuality = .high
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return Raster(width: width, height: height, pixels: pixels)
    }

    private static func perceptualSimilarity(_ lhs: Raster, _ rhs: Raster) -> Double {
        var difference = 0.0
        for index in stride(from: 0, to: lhs.pixels.count, by: 4) {
            difference += abs(Double(lhs.pixels[index]) - Double(rhs.pixels[index]))
            difference += abs(Double(lhs.pixels[index + 1]) - Double(rhs.pixels[index + 1]))
            difference += abs(Double(lhs.pixels[index + 2]) - Double(rhs.pixels[index + 2]))
        }
        let maximum = Double(lhs.width * lhs.height * 3 * 255)
        return 1 - difference / maximum
    }

    private static func edgeSimilarity(_ lhs: Raster, _ rhs: Raster) -> Double {
        let lhsEdges = edgeMap(lhs)
        let rhsEdges = edgeMap(rhs)
        let difference = zip(lhsEdges, rhsEdges).reduce(0.0) {
            $0 + abs($1.0 - $1.1)
        }
        return max(0, 1 - difference / Double(lhsEdges.count))
    }

    private static func edgeMap(_ raster: Raster) -> [Double] {
        let grayscale = grayscaleValues(raster)
        var edges = [Double](repeating: 0, count: grayscale.count)
        for y in 1..<raster.height {
            for x in 1..<raster.width {
                let index = y * raster.width + x
                let horizontal = abs(grayscale[index] - grayscale[index - 1])
                let vertical = abs(grayscale[index] - grayscale[index - raster.width])
                edges[index] = min(1, horizontal + vertical)
            }
        }
        return edges
    }

    private static func grayscaleValues(_ raster: Raster) -> [Double] {
        stride(from: 0, to: raster.pixels.count, by: 4).map { index in
            let red = Double(raster.pixels[index]) / 255
            let green = Double(raster.pixels[index + 1]) / 255
            let blue = Double(raster.pixels[index + 2]) / 255
            return 0.2126 * red + 0.7152 * green + 0.0722 * blue
        }
    }

    private static func inkDice(_ lhs: Raster, _ rhs: Raster) -> Double {
        let lhsMask = inkMask(lhs)
        let rhsMask = inkMask(rhs)
        var lhsCount = 0
        var rhsCount = 0
        var intersection = 0

        for index in lhsMask.indices {
            if lhsMask[index] { lhsCount += 1 }
            if rhsMask[index] { rhsCount += 1 }
            if lhsMask[index] && rhsMask[index] { intersection += 1 }
        }
        let total = lhsCount + rhsCount
        return total == 0 ? 1 : Double(2 * intersection) / Double(total)
    }

    private static func inkMask(_ raster: Raster) -> [Bool] {
        let corners = [
            0,
            (raster.width - 1) * 4,
            (raster.height - 1) * raster.width * 4,
            (raster.height * raster.width - 1) * 4,
        ]
        let background = (0..<3).map { channel in
            corners.map { Double(raster.pixels[$0 + channel]) / 255 }
                .reduce(0, +) / Double(corners.count)
        }

        return stride(from: 0, to: raster.pixels.count, by: 4).map { index in
            let red = Double(raster.pixels[index]) / 255 - background[0]
            let green = Double(raster.pixels[index + 1]) / 255 - background[1]
            let blue = Double(raster.pixels[index + 2]) / 255 - background[2]
            return sqrt(red * red + green * green + blue * blue) > 0.035
        }
    }

    private static func writeDiff(_ lhs: Raster, _ rhs: Raster, to url: URL) throws {
        guard
            let representation = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: lhs.width,
                pixelsHigh: lhs.height,
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bitmapFormat: [],
                bytesPerRow: lhs.width * 4,
                bitsPerPixel: 32
            ),
            let bitmap = representation.bitmapData
        else {
            throw CheckerError.cannotCreateDiff
        }

        for index in stride(from: 0, to: lhs.pixels.count, by: 4) {
            let difference = (
                abs(Int(lhs.pixels[index]) - Int(rhs.pixels[index]))
                    + abs(Int(lhs.pixels[index + 1]) - Int(rhs.pixels[index + 1]))
                    + abs(Int(lhs.pixels[index + 2]) - Int(rhs.pixels[index + 2]))
            ) / 3
            bitmap[index] = UInt8(min(255, difference * 4))
            bitmap[index + 1] = UInt8(min(255, difference))
            bitmap[index + 2] = UInt8(min(255, difference))
            bitmap[index + 3] = 255
        }

        guard let data = representation.representation(using: .png, properties: [:]) else {
            throw CheckerError.cannotCreateDiff
        }
        try data.write(to: url, options: .atomic)
    }

    private static func ratioSimilarity(_ lhs: Double, _ rhs: Double) -> Double {
        min(lhs, rhs) / max(lhs, rhs)
    }

    private static func rounded(_ value: Double) -> Double {
        (value * 10_000).rounded() / 10_000
    }
}

private enum CheckerError: Error {
    case cannotReadImage(String)
    case cannotCreateDiff
}
