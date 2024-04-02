//
//  SBGalleryInteractor.swift
//  SlimBody
//
//  Created by Anastasia Kravchenko on 22.09.2023.
//

import UIKit

class SBGalleryInteractor: NSObject {

    static let sharedInstance: SBGalleryInteractor = SBGalleryInteractor()

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
