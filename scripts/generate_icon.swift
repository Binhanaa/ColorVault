import AppKit

func generateIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext

    // 1. Apple squircle rounded rectangle
    let cornerRadius = s * 0.2237 // Apple standard icon continuous corner radius
    let rect = CGRect(x: s * 0.05, y: s * 0.05, width: s * 0.9, height: s * 0.9)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.04), blur: s * 0.08, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    ctx.addPath(path)
    ctx.setFillColor(NSColor.black.cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // Background Gradient (Dark Indigo to Midnight Slate)
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()

    let colors = [
        NSColor(red: 0.12, green: 0.12, blue: 0.22, alpha: 1.0).cgColor,
        NSColor(red: 0.06, green: 0.07, blue: 0.14, alpha: 1.0).cgColor
    ] as CFArray
    let space = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: s * 0.5, y: s * 0.95), end: CGPoint(x: s * 0.5, y: s * 0.05), options: [])

    // Decorative Color Spectrum Arc / Rings inside
    let paletteColors: [NSColor] = [
        NSColor(red: 0.96, green: 0.26, blue: 0.38, alpha: 0.95), // Coral
        NSColor(red: 0.98, green: 0.55, blue: 0.15, alpha: 0.95), // Orange
        NSColor(red: 0.96, green: 0.75, blue: 0.15, alpha: 0.95), // Amber
        NSColor(red: 0.16, green: 0.80, blue: 0.55, alpha: 0.95), // Mint
        NSColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 0.95), // Blue
        NSColor(red: 0.65, green: 0.35, blue: 0.96, alpha: 0.95)  // Purple
    ]

    let center = CGPoint(x: s * 0.5, y: s * 0.5)
    let radius = s * 0.26

    for (i, col) in paletteColors.enumerated() {
        let angle = Double(i) * (2.0 * .pi / Double(paletteColors.count)) - (.pi / 2.0)
        let cx = center.x + CGFloat(cos(angle)) * radius
        let cy = center.y + CGFloat(sin(angle)) * radius
        let dotRadius = s * 0.085

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.015), blur: s * 0.03, color: col.withAlphaComponent(0.5).cgColor)
        ctx.setFillColor(col.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - dotRadius, y: cy - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
        ctx.restoreGState()
    }

    // Center Core Gem (Vault Prism)
    let coreRadius = s * 0.11
    ctx.saveGState()
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.92).cgColor)
    ctx.fillEllipse(in: CGRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2))
    ctx.restoreGState()

    // Inner Border
    ctx.addPath(path)
    ctx.setLineWidth(s * 0.015)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.18).cgColor)
    ctx.strokePath()

    ctx.restoreGState()

    image.unlockFocus()
    return image
}

let iconsetPath = "/tmp/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconsetPath)
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true, attributes: nil)

let sizes: [(Int, Int, String)] = [
    (16, 1, "icon_16x16.png"),
    (16, 2, "icon_16x16@2x.png"),
    (32, 1, "icon_32x32.png"),
    (32, 2, "icon_32x32@2x.png"),
    (128, 1, "icon_128x128.png"),
    (128, 2, "icon_128x128@2x.png"),
    (256, 1, "icon_256x256.png"),
    (256, 2, "icon_256x256@2x.png"),
    (512, 1, "icon_512x512.png"),
    (512, 2, "icon_512x512@2x.png")
]

for (pt, scale, filename) in sizes {
    let px = pt * scale
    let img = generateIcon(size: px)
    if let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let dest = "\(iconsetPath)/\(filename)"
        try? png.write(to: URL(fileURLWithPath: dest))
    }
}

print("Iconset created successfully")
