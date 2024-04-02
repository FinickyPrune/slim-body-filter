//
//  SBFilter.swift
//  SlimBody
//
//  Created by Anastasia Kravchenko on 22.09.2023.
//

import Foundation
import CoreImage

// Filter names

enum SBFilterName: String {
    case none = ""
    case blur = "Blur"
    case slimBody = "Slim Body"
}

// Filter types

enum SBFilterType {
    case none
    case background
    case foreground
}

/// Class inherites CIFilter class and represents in-app filter. Inherit from this class in case you want to create new filter.

class SBFilter: CIFilter {

    // Override this properties in every new filter.
    open var filterName: SBFilterName = .none
    open var displayFilterName: String = ""
    open var filterType: SBFilterType = .none
    open var kernel: CIKernel?

    open var inputImage: CIImage?

    func setIntensivity(value: Float) {
        intensivity = maxIntensivity * value
    }

    open var intensivity: Float = 0.0
    public let maxIntensivity: Float = 50.0

    open var normalizerdFilterValue: Float {
        intensivity / maxIntensivity
    }

    // Override this method in every new filter.
    func outputImage() -> CIImage? { return nil }

}
