import Foundation
import CoreGraphics
import Metal

final class Blur: Filter {

    var inputImage: CGImage?
    
    func setIntensivity(value: Float) {
        intensivity = maxIntensivity * value
    }
        
    var filterName: FilterName { .blur }

    var filterType: FilterType { .background }

    var displayFilterName: String { filterName.rawValue }
    
    var intensivity: Float = 0.0
    let maxIntensivity: Float = 50.0
    
    var normalizerdFilterValue: Float {
        intensivity / maxIntensivity
    }

    // Initializer creates filter kernel with default metal library and relevant metal function name.
    private let context: MTLContext
    
    let pipelineState: MTLComputePipelineState
    
    init?() {
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = try? device.makeDefaultLibrary(bundle: Bundle.main),
              let function = library.makeFunction(name: "blur"),
              let pipelineState = try? device.makeComputePipelineState(function: function) else {
                  return nil
        }
           
        self.pipelineState = pipelineState
        
        guard let context = try? MTLContext(),
              let library = try? context.library(for: Blur.self),
              let pipelineState = try? library.computePipelineState(function: "blur") else {
            return nil
        }
        self.context = context
    }
    
    private func encode(input: MTLTexture,
                        output: MTLTexture,
                        intensity: Float,
                        in commandBuffer: MTLCommandBuffer) {
        commandBuffer.compute { encoder in
            encoder.setTextures([input, output])
            encoder.setValue(Int(intensivity), at: 0)
            
            encoder.dispatch2d(state: self.pipelineState,
                               exactly: output.size)
        }
    }

    // Returns output CIImage created with filter kernel.

    func outputImage() throws -> CGImage? {
        guard let inputImage = inputImage else { return nil }
        
        let inputTexture = try context.texture(from: inputImage)
        let outputTexture = try inputTexture.matchingTexture(usage: [.shaderWrite])
        
        try context.scheduleAndWait { buffer in
            self.encode(
                input: inputTexture,
                output: outputTexture,
                intensity: self.intensivity,
                in: buffer
            )
        }
        
        return try outputTexture.cgImage()
    }
}
