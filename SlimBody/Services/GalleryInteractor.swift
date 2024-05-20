import UIKit

final class GalleryInteractor: NSObject {

    static let sharedInstance: GalleryInteractor = GalleryInteractor()

    private var completion: (() -> Void)?

    func saveToGallery(_ image: UIImage?, completion: @escaping () -> Void) {
        guard let image = image else {
            return
        }

        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            completion = nil
            return
        }
        completion?()
        completion = nil
    }

}
