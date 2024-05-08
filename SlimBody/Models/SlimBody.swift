import Foundation
import CoreImage

class SlimBody: SBFilter {

    override var filterName: SBFilterName {
        get { return .slimBody }
        set {}
    }

    override var filterType: SBFilterType {
        get { return .foreground }
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

    // Property represents how many pixels in one screen point. Used to translate SlimBodyView size on CIImage.

    var pointToPixelScale: CGFloat = 1.0

    // Transform is used to tell flter about changes of filter area. (size, scale, rotation)

    var transform: CGAffineTransform = .identity

    // Initializer creates filter kernel with default metal library and relevant metal function name.

    override init() {
        super.init()
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url),
              let kern = try? CIKernel(functionName: "slim_body", fromMetalLibraryData: data)
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
        let invertedTransform = transform.inverted()
        let output =  kernel?.apply(extent: inputImage.extent,
                                    roiCallback: roiCallback,
                                    arguments: [inputImage,
                                                SlimBodyView.initialWidth * pointToPixelScale,
                                                SlimBodyView.initialHeight * pointToPixelScale,
                                                width,
                                                height,
                                                Int(intensivity),

                                                //                                      Pass transform values to kernel.

                                                transform.a, transform.b, transform.c, transform.d,
                                                transform.tx * pointToPixelScale,
                                                transform.ty * pointToPixelScale,

                                                //                                      Pass inverted transform values to kernel.

                                                invertedTransform.a,
                                                invertedTransform.b,
                                                invertedTransform.c,
                                                invertedTransform.d,
                                                invertedTransform.tx * pointToPixelScale,
                                                invertedTransform.ty * pointToPixelScale])
        return output
    }
}
