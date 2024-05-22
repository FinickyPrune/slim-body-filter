enum MetalError {
    enum MTLContextError: Error {
        case textureCacheCreationFailed
    }
    enum MTLDeviceError: Error {
        case argumentEncoderCreationFailed
        case bufferCreationFailed
        case depthStencilStateCreationFailed
        case eventCreationFailed
        case fenceCreationFailed
        case heapCreationFailed
        case indirectCommandBufferCreationFailed
        case libraryCreationFailed
        case rasterizationRateMapCreationFailed
        case samplerStateCreationFailed
        case textureCreationFailed
        case textureViewCreationFailed
    }
    enum MTLHeapError: Error {
        case bufferCreationFailed
        case textureCreationFailed
    }
    enum MTLCommandQueueError: Error {
        case commandBufferCreationFailed
    }
    enum MTLLibraryError: Error {
        case functionCreationFailed
    }
    enum MTLTextureSerializationError: Error {
        case allocationFailed
        case dataAccessFailure
        case unsupportedPixelFormat
    }
    enum MTLTextureError: Error {
        case imageCreationFailed
        case imageIncompatiblePixelFormat
        case incompatibleStorageMode
        case pixelBufferConversionFailed
    }
    enum MTLBufferError: Error {
        case incompatibleData
    }
}
