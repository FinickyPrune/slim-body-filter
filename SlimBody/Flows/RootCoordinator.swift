import UIKit

class RootCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        pushMainController()
    }

    private func pushMainController() {
        let viewController = SBMainViewController()
        let viewModel = SBMainViewModel()
        viewModel.displayDelegate = viewController
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: false)
    }

}
