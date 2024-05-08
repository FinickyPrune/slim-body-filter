import UIKit

enum PinchDirection {
    case horizontal
    case vertical
    case mixed
    case none
}

class SlimBodyView: UIView {

    static let initialWidth: CGFloat = 160
    static let initialHeight: CGFloat = 160

    var pinchDirection = PinchDirection.none

    //    Properties for hyperbola drawing
    private var a: CGFloat = 1
    private var b: CGFloat = 1
    private let a_devider = 2.6
    private let b_devider = 1.5
    private let color = UIColor.blue
    private var lineWidth: CGFloat {
        5 / transform.a
    }

    //    Draws hyperbola in view. First creates points arrays for left and right arcs. Then draws arcs based on this points.
    override func draw(_ rect: CGRect) {
        a = rect.width / a_devider
        b = rect.height / b_devider
        color.setStroke()

        let width = Int(rect.width)
        var points1: [CGPoint] = []
        var points2: [CGPoint] = []

        for i in (-width/2...width/2) {
            if i < 0 {
                let y1 = hyperbola(x: CGFloat(i))
                let y2 = -1 * hyperbola(x: CGFloat(i))
                points1.append(CGPoint(x: CGFloat(i) + rect.midX, y: y1 + rect.midY))
                points1.append(CGPoint(x: CGFloat(i) + rect.midX, y: y2 + rect.midY))
            } else if i > 0 {
                let y1 = hyperbola(x: CGFloat(i))
                let y2 = -1 * hyperbola(x: CGFloat(i))
                points2.append(CGPoint(x: CGFloat(i) + rect.midX, y: y1 + rect.midY))
                points2.append(CGPoint(x: CGFloat(i) + rect.midX, y: y2 + rect.midY))
            }
        }

        points1.sort(by: { $0.y < $1.y })
        points2.sort(by: { $0.y < $1.y })
        points1.removeAll(where: { $0.y.isNaN })
        points2.removeAll(where: { $0.y.isNaN })

        let path1 = UIBezierPath()
        let path2 = UIBezierPath()
        path1.lineWidth = lineWidth
        path2.lineWidth = lineWidth
        for i in (0...points1.count - 2) {
            path1.move(to: points1[i])
            path1.addLine(to: points1[i+1])
        }
        for i in (0...points2.count - 2) {
            path2.move(to: points2[i])
            path2.addLine(to: points2[i+1])
        }

        path1.stroke()
        path2.stroke()
    }

    /// Canonical hyperbola formula: (x/a)^2 - (y/b)^2 = 1. So y  = sqrt((x*b/a)^2 - b^2)
    private func hyperbola(x: CGFloat) -> CGFloat {
        return sqrt(((x*x)*(b*b)/(a*a) - (b*b)))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
