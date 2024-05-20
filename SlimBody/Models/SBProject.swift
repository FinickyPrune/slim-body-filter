import UIKit
import CoreImage

/// This class represents in-app project, stores all needed images and filters settings (filter intensivity values and processed images)

final class SBProject {

    private let originalImage: CIImage?
    private(set) var filteredImage: CIImage?

    var filterValue: Float = 0.0

    var processedImage: CIImage?

    init(originalImage: UIImage) {
        self.originalImage = CIImage(image: originalImage)
        self.filteredImage = self.originalImage
        self.processedImage = filteredImage
    }

    var finalImage: UIImage? {
        guard let filteredImage = processedImage else { return nil }
        let image = UIImage(ciImage: filteredImage)

        let size = image.size
        UIGraphicsBeginImageContext(size)

        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        image.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()
        return finalImage
    }
}
