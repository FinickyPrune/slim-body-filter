import UIKit
import CoreImage

protocol SBMainViewModelDisplayDelegate: AnyObject {
    func viewModelDidRequestReloadingViews(_ viewModel: SBMainViewModel)
    func viewModel(_ viewModel: SBMainViewModel, didChangeSlimBodyConfiguratorVisibility shouldShow: Bool)
    func viewModel(_ viewModel: SBMainViewModel, didRequestShowingMessage message: String)
    func viewModel(_ viewModel: SBMainViewModel, didSelectImage image: CGImage)
}

final class SBMainViewModel {

    weak var displayDelegate: SBMainViewModelDisplayDelegate?

    /// Only for PoC. In future Data Source needs to be implemented
    private var filters: [SBFilter] {
        return [Brightness(), Blur()].compactMap { $0 as? SBFilter }
    }

    var currentProject: SBProject?
    var selectedFilter: SBFilter?

    /// A value associated with selected filter. Usually represents intensity.
    var selectedFilterValue: Float {
        currentProject?.filterValue ?? 0.0
    }

    var currentImage: CGImage? {
        currentProject?.filteredImage
    }

    var filtersCount: Int {
        filters.count
    }

    func displayFilterNameFor(index: Int) -> String {
        filters[index].displayFilterName
    }

    func didTapSave() {
        guard let image = currentProject?.finalImage else { return }
        GalleryInteractor.sharedInstance.saveToGallery(image) { [self] in
            self.displayDelegate?.viewModel(self, didRequestShowingMessage: "MainViewController.saveSuccessMessage".localized)
        }
    }

    func didPick(_ image: UIImage) {
        currentProject = SBProject(originalImage: image)
        displayDelegate?.viewModelDidRequestReloadingViews(self)
    }

    func didSelectFilterWith(index: Int) {
        selectedFilter = filters[index]
        selectedFilter?.inputImage = currentProject?.filteredImage
        if selectedFilter?.filterName == .slimBody {
            displayDelegate?.viewModel(self, didChangeSlimBodyConfiguratorVisibility: true)
        } else {
            displayDelegate?.viewModel(self, didChangeSlimBodyConfiguratorVisibility: false)
        }
    }

    func didChangeFilterValue(_ value: Float) {
        guard let processedCIImage = applyFilter(value: value) else { return }
        displayDelegate?.viewModel(self, didSelectImage: processedCIImage)
    }

    private func applyFilter(value: Float = 0.0) -> CGImage? {
        selectedFilter?.setIntensivity(value: value)
        return try? selectedFilter?.outputImage()
    }

    /// Saves current associated value (intensity) into the project
    func didAcceptValue() {
        guard let currentProgect = currentProject, let selectedFilter = selectedFilter else { return }
        currentProgect.filterValue = selectedFilter.normalizerdFilterValue
        currentProgect.processedImage = applyFilter(value: currentProgect.filterValue)
    }

    /// Reverts current associated value (intensity) to a previously saved value, stored inside current project
    func didCancelValue() {
        guard let currentProgect = currentProject else { return }
        didChangeFilterValue(currentProgect.filterValue)
    }

    // MARK: - Slim Body Section

    func didChangeSlimBody(_ pointToPixelScale: CGFloat) {
//        guard let filter = selectedFilter as? SlimBody else { return }
//        filter.pointToPixelScale = pointToPixelScale
    }

    func didChangeSlimBody(_ transform: CGAffineTransform) {
//        guard let filter = selectedFilter as? SlimBody else { return }
//        filter.transform = transform
    }

}
