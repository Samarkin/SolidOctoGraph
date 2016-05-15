import Cocoa

class OctoGraphView: NSView {
    private let colors: [NSColor] = [
        .blackColor(),
        .redColor(),
        .blueColor(),
        .greenColor(),
    ]
    private var min: Double = 0
    private var max: Double = 0
    private var cache: [Cache<Double>] = []

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var throttle = 0

    private var cnt = 0
    func push(arr: [Double]) {
        while cache.count < arr.count {
            cache.append(Cache<Double>(limit: 2048))
        }
        for (i,d) in arr.enumerate() {
            if (++cnt) > 100 {
                min = Swift.min(min, d, 0)
                max = Swift.max(max, d, 0)
                cache[i].push(d)
            }
        }
        if ++throttle > 0 {
            self.setNeedsDisplayInRect(NSRect(origin: NSZeroPoint, size: frame.size))
            throttle = 0
        }
    }

    private func normalize(y: Double) -> Double {
        return (y - min) * Double(frame.size.height) / (max - min)
    }

    override func drawRect(dirtyRect: NSRect) {
        assert(cache.count <= colors.count, "Please add more colors")

        let redrawRect = NSRect(origin: NSZeroPoint, size: frame.size)
        // erase the background by drawing white
        NSColor.whiteColor().set()
        NSBezierPath.fillRect(redrawRect)

        if abs(min - max) < 1e-6 {
            return
        }

        let ny = normalize(0)

        let minString: NSString = NSString(format: "%0.2f", min)
        let minSize = minString.sizeWithAttributes(nil)
        let maxString: NSString = NSString(format: "%0.2f", max)
        let maxSize = maxString.sizeWithAttributes(nil)
        let nx = Int(frame.size.width - Swift.max(minSize.width, maxSize.width))

        NSColor.blackColor().set()
        if abs(min) > 1e-6 && abs(max) > 1e-6 {
            let zero: NSString = "0.00"
            zero.drawAtPoint(NSPoint(x: Double(nx), y: ny), withAttributes: nil)
        }
        minString.drawAtPoint(NSPoint(x: nx, y: 0), withAttributes: nil)
        maxString.drawAtPoint(NSPoint(x: CGFloat(nx), y: frame.size.height-maxSize.height), withAttributes: nil)

        // x-axis
        NSColor.grayColor().set()
        NSBezierPath.strokeLineFromPoint(NSPoint(x: Double(0), y: ny), toPoint: NSPoint(x: Double(nx), y: ny))

        var generators = cache.map{$0.generate()}
        var last_y: [Double?] = Array(count: generators.count, repeatedValue: nil)
        for var x = Int(nx) - 1; x >= 0; x-- {
            for i in 0..<generators.count {
                colors[i].set()
                if var y = generators[i].next() {
                    y = normalize(y)
                    if let ly = last_y[i] {
                        NSBezierPath.strokeLineFromPoint(NSPoint(x: Double(x+1), y: ly), toPoint: NSPoint(x: Double(x), y: y))
                    }
                    last_y[i] = y
                }
            }
        }
    }

}