import Metal

extension MTLLibrary {

    func computePipelineState(function functionName: String) throws -> MTLComputePipelineState {
        guard let function = self.makeFunction(name: functionName) else {
            throw MetalError.MTLLibraryError.functionCreationFailed
        }
        return try self.device.makeComputePipelineState(function: function)
    }

}
