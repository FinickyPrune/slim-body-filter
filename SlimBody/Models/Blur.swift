import Foundation
import CoreImage

final class Blur: SBFilter {

    override var filterName: SBFilterName {
        get { return .blur }
        set {}
    }

    override var filterType: SBFilterType {
        get { return .background }
        set {}
    }

    override var displayFilterName: String {
        get { return filterName.rawValue }
        set {}
    }

    // Property represents region of interest of filter. In this case return value is whole image.

    private let roiCallback: CIKernelROICallback = { _, rect -> CGRect in
        return rect
    }

    // Initializer creates filter kernel with default metal library and relevant metal function name.

    override init() {
        super.init()
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url),
              let kern = try? CIKernel(functionName: "blur", fromMetalLibraryData: data)
        else { fatalError() }

        self.kernel = kern
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Returns output CIImage created with filter kernel.

    override func outputImage() -> CIImage? {
        guard let inputImage = inputImage else { return nil }
        let width = inputImage.extent.width
        let height = inputImage.extent.height
        return kernel?.apply(extent: inputImage.extent,
                             roiCallback: roiCallback,
                             arguments: [inputImage,
                                         width,
                                         height,
                                         Int(intensivity)])
    }
}
