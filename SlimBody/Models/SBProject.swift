import UIKit
import CoreImage

/// This class represents in-app project, stores all needed images and filters settings (filter intensivity values and processed images)

final class SBProject {

    private let originalImage: CGImage?
    private(set) var filteredImage: CGImage?

    var filterValue: Float = 0.0

    var processedImage: CGImage?

    init(originalImage: UIImage) {
        self.originalImage = originalImage.cgImage
        self.filteredImage = self.originalImage
        self.processedImage = filteredImage
    }

    var finalImage: UIImage? {
        guard let filteredImage = processedImage else { return nil }
        let image = UIImage(cgImage: filteredImage)

        let size = image.size
        UIGraphicsBeginImageContext(size)

        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        image.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()
        return finalImage
    }
}
