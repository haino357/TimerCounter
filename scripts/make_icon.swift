// アプリアイコン（AppIcon.appiconset）の PNG を生成する。
// 使い方: swift scripts/make_icon.swift TimerCounter/Assets.xcassets/AppIcon.appiconset
import AppKit

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: make_icon.swift <AppIcon.appiconset>\n".utf8))
    exit(1)
}
let outDir = URL(fileURLWithPath: CommandLine.arguments[1])

/// 1024pt のキャンバスに描いたアイコンを、指定ピクセル数で書き出す。
func render(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: pixels, height: pixels)

    NSGraphicsContext.saveGraphicsState()
    defer { NSGraphicsContext.restoreGraphicsState() }
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    let scale = CGFloat(pixels) / 1024
    ctx.scaleBy(x: scale, y: scale)

    // 背景: macOS のアイコングリッドに合わせた角丸四角（824pt、余白 100pt）
    let shape = NSBezierPath(
        roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824),
        xRadius: 185, yRadius: 185)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 24,
                  color: NSColor.black.withAlphaComponent(0.3).cgColor)
    NSColor.black.setFill()
    shape.fill()
    ctx.restoreGState()
    NSGradient(
        starting: NSColor(srgbRed: 1.00, green: 0.48, blue: 0.33, alpha: 1),
        ending: NSColor(srgbRed: 0.87, green: 0.20, blue: 0.22, alpha: 1)
    )!.draw(in: shape, angle: -90)

    // タイマーのリング: 薄い一周の上に、残り時間を表す 3/4 の弧
    let center = NSPoint(x: 512, y: 512)
    let track = NSBezierPath()
    track.appendArc(withCenter: center, radius: 250, startAngle: 0, endAngle: 360)
    track.lineWidth = 60
    NSColor.white.withAlphaComponent(0.3).setStroke()
    track.stroke()

    let arc = NSBezierPath()
    arc.appendArc(withCenter: center, radius: 250, startAngle: 90, endAngle: -180, clockwise: true)
    arc.lineWidth = 60
    arc.lineCapStyle = .round
    NSColor.white.setStroke()
    arc.stroke()

    // カウンター: 完了すると 1 増えることを表す「+1」
    let base = NSFont.systemFont(ofSize: 200, weight: .bold)
    let font = base.fontDescriptor.withDesign(.rounded).flatMap { NSFont(descriptor: $0, size: 200) } ?? base
    let text = NSAttributedString(string: "+1", attributes: [.font: font, .foregroundColor: NSColor.white])
    let size = text.size()
    text.draw(at: NSPoint(x: center.x - size.width / 2, y: center.y - size.height / 2))

    return rep.representation(using: .png, properties: [:])!
}

for pixels in [16, 32, 64, 128, 256, 512, 1024] {
    try render(pixels: pixels).write(to: outDir.appendingPathComponent("icon_\(pixels).png"))
}
