import Foundation
import CoreImage

// Filter names

enum FilterName: String {
    case none = ""
    case blur = "Blur"
    case slimBody = "Slim Body"
    case brightness = "Brightness"
}

// Filter types

enum FilterType {
    case none
    case background
    case foreground
}

/// Class inherites CIFilter class and represents in-app filter. Inherit from this class in case you want to create new filter.

protocol Filter {

    var filterName: FilterName { get }
    var displayFilterName: String { get }
    var filterType: FilterType { get }
    
    var maxIntensivity: Float { get }
    var normalizerdFilterValue: Float { get }

    var inputImage: CGImage? { get set }
    var intensivity: Float { get set }
    
    func setIntensivity(value: Float)
    func outputImage() throws -> CGImage?
}
