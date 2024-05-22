import Metal
import UIKit
import Accelerate

extension MTLTexture {
    #if os(iOS) || os(tvOS)
    typealias XImage = UIImage
    #elseif os(macOS)
    typealias XImage = NSImage
    #endif
    
    var descriptor: MTLTextureDescriptor {
           let retVal = MTLTextureDescriptor()
           
           retVal.width = width
           retVal.height = height
           retVal.depth = depth
           retVal.arrayLength = arrayLength
           retVal.storageMode = storageMode
           retVal.cpuCacheMode = cpuCacheMode
           retVal.usage = usage
           retVal.textureType = textureType
           retVal.sampleCount = sampleCount
           retVal.mipmapLevelCount = mipmapLevelCount
           retVal.pixelFormat = pixelFormat
           if #available(iOS 12, macOS 10.14, *) {
               retVal.allowGPUOptimizedContents = allowGPUOptimizedContents
           }
           
           return retVal
       }
    
    var region: MTLRegion {
        return MTLRegion(origin: .zero,
                         size: self.size)
    }
    
    var size: MTLSize {
            return MTLSize(width: self.width,
                           height: self.height,
                           depth: self.depth)
        }
    
    func matchingTexture(usage: MTLTextureUsage? = nil,
                         storage: MTLStorageMode? = nil) throws -> MTLTexture {
        let matchingDescriptor = self.descriptor
        
        if let u = usage {
            matchingDescriptor.usage = u
        }
        if let s = storage {
            matchingDescriptor.storageMode = s
        }

        guard let matchingTexture = self.device.makeTexture(descriptor: matchingDescriptor)
        else {
            throw MetalError.MTLDeviceError.textureCreationFailed
        }
        
        return matchingTexture
    }
    
    func cgImage(colorSpace: CGColorSpace? = nil) throws -> CGImage {
        guard self.isAccessibleOnCPU
        else {
            throw MetalError.MTLTextureError.imageCreationFailed
        }

        switch self.pixelFormat {
        case .a8Unorm, .r8Unorm, .r8Uint:
            let rowBytes = self.width
            let length = rowBytes * self.height

            let rgbaBytes = UnsafeMutableRawPointer.allocate(byteCount: length,
                                                             alignment: MemoryLayout<UInt8>.alignment)
            defer { rgbaBytes.deallocate() }
            self.getBytes(rgbaBytes,
                          bytesPerRow: rowBytes,
                          from: self.region,
                          mipmapLevel: 0)

            let colorScape = colorSpace ?? CGColorSpaceCreateDeviceGray()
            let bitmapInfo = CGBitmapInfo(rawValue: self.pixelFormat == .a8Unorm
                                                    ? CGImageAlphaInfo.alphaOnly.rawValue
                                                    : CGImageAlphaInfo.none.rawValue)
            guard let data = CFDataCreate(nil,
                                          rgbaBytes.assumingMemoryBound(to: UInt8.self),
                                          length),
                  let dataProvider = CGDataProvider(data: data),
                  let cgImage = CGImage(width: self.width,
                                        height: self.height,
                                        bitsPerComponent: 8,
                                        bitsPerPixel: 8,
                                        bytesPerRow: rowBytes,
                                        space: colorScape,
                                        bitmapInfo: bitmapInfo,
                                        provider: dataProvider,
                                        decode: nil,
                                        shouldInterpolate: true,
                                        intent: .defaultIntent)
            else {
                throw MetalError.MTLTextureError.imageCreationFailed
            }

            return cgImage
        case .bgra8Unorm, .bgra8Unorm_srgb:
            // read texture as byte array
            let rowBytes = self.width * 4
            let length = rowBytes * self.height

            let bgraBytes = UnsafeMutableRawPointer.allocate(byteCount: length,
                                                             alignment: MemoryLayout<UInt8>.alignment)
            defer { bgraBytes.deallocate() }

            self.getBytes(bgraBytes,
                          bytesPerRow: rowBytes,
                          from: self.region,
                          mipmapLevel: 0)

            // use Accelerate framework to convert from BGRA to RGBA
            var bgraBuffer = vImage_Buffer(data: bgraBytes,
                                           height: vImagePixelCount(self.height),
                                           width: vImagePixelCount(self.width),
                                           rowBytes: rowBytes)

            let rgbaBytes = UnsafeMutableRawPointer.allocate(byteCount: length,
                                                             alignment: MemoryLayout<UInt8>.alignment)
            defer { rgbaBytes.deallocate() }
            var rgbaBuffer = vImage_Buffer(data: rgbaBytes,
                                           height: vImagePixelCount(self.height),
                                           width: vImagePixelCount(self.width),
                                           rowBytes: rowBytes)
            let map: [UInt8] = [2, 1, 0, 3]
            vImagePermuteChannels_ARGB8888(&bgraBuffer,
                                           &rgbaBuffer,
                                           map, 0)

            // create CGImage with RGBA Flipped Bytes
            let colorScape = colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard let data = CFDataCreate(nil,
                                          rgbaBytes.assumingMemoryBound(to: UInt8.self),
                                          length),
                  let dataProvider = CGDataProvider(data: data),
                  let cgImage = CGImage(width: self.width,
                                        height: self.height,
                                        bitsPerComponent: 8,
                                        bitsPerPixel: 32,
                                        bytesPerRow: rowBytes,
                                        space: colorScape,
                                        bitmapInfo: bitmapInfo,
                                        provider: dataProvider,
                                        decode: nil,
                                        shouldInterpolate: true,
                                        intent: .defaultIntent)
            else {
                throw MetalError.MTLTextureError.imageCreationFailed
            }

            return cgImage
        case .rgba8Unorm, .rgba8Unorm_srgb:
            let rowBytes = self.width * 4
            let length = rowBytes * self.height

            let rgbaBytes = UnsafeMutableRawPointer.allocate(byteCount: length,
                                                             alignment: MemoryLayout<UInt8>.alignment)
            defer { rgbaBytes.deallocate() }

            self.getBytes(rgbaBytes,
                          bytesPerRow: rowBytes,
                          from: self.region,
                          mipmapLevel: 0)

            let colorScape = colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard let data = CFDataCreate(nil,
                                          rgbaBytes.assumingMemoryBound(to: UInt8.self),
                                          length),
                  let dataProvider = CGDataProvider(data: data),
                  let cgImage = CGImage(width: self.width,
                                        height: self.height,
                                        bitsPerComponent: 8,
                                        bitsPerPixel: 32,
                                        bytesPerRow: rowBytes,
                                        space: colorScape,
                                        bitmapInfo: bitmapInfo,
                                        provider: dataProvider,
                                        decode: nil,
                                        shouldInterpolate: true,
                                        intent: .defaultIntent)
            else {
                throw MetalError.MTLTextureError.imageCreationFailed
            }

            return cgImage
        default: throw MetalError.MTLTextureError.imageIncompatiblePixelFormat
        }
    }
    
    func image(colorSpace: CGColorSpace? = nil) throws -> XImage {
        let cgImage = try self.cgImage(colorSpace: colorSpace)
        #if os(iOS)
        return UIImage(cgImage: cgImage)
        #elseif os(macOS)
        return NSImage(cgImage: cgImage,
                       size: CGSize(width: cgImage.width,
                                    height: cgImage.height))
        #endif
    }
}
