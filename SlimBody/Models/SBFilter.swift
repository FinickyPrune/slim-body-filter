import Foundation
import CoreImage

// Filter names

enum SBFilterName: String {
    case none = ""
    case blur = "Blur"
    case slimBody = "Slim Body"
    case brightness = "Brightness"
}

// Filter types

enum SBFilterType {
    case none
    case background
    case foreground
}

/// Class inherites CIFilter class and represents in-app filter. Inherit from this class in case you want to create new filter.

protocol SBFilter {

    // Override this properties in every new filter.
    var filterName: SBFilterName { get }
    var displayFilterName: String { get }
    var filterType: SBFilterType { get }

    var inputImage: CGImage? { get set }

    func setIntensivity(value: Float)
    
    var intensivity: Float { get set }
    var maxIntensivity: Float { get }
    
    var normalizerdFilterValue: Float { get }
    func outputImage() throws -> CGImage?
    
    

}

extension MTLLibrary {

    func computePipelineState(function functionName: String) throws -> MTLComputePipelineState {
        guard let function = self.makeFunction(name: functionName) else {
            throw MetalError.MTLLibraryError.functionCreationFailed
        }
        return try self.device.makeComputePipelineState(function: function)
    }

}
