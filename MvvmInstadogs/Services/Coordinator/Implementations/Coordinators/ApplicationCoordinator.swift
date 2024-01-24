import Combine
import UIKit

class ApplicationCoordinator: BaseCoordinator<Void, Never> {
    private let tabBarController: TabBarController

    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
    }

    override func run() {
        configureTabBarModule()
    }
}

// MARK: - Modules

extension ApplicationCoordinator {
    private func configureTabBarModule() {
        tabBarController.viewControllers = [dogsViewModule(), favouriteDogsViewModule()]
        tabBarController.completion.sink { completion in
            switch completion {
            case .dogsViewOpened(let viewController):
                (viewController as? DogsViewController)?.scrollToTop()
            case .favouriteDogsViewOpened(let viewController):
                (viewController as? FavouriteDogsViewController)?.scrollToTop()
            }
        }.store(in: &subscriptions)
    }

    private func dogsViewModule() -> DogsViewController {
        let view = DogsModuleFactory().module()

        view.completion.sink { [weak view] completion in
            if case .openPreview(let image, let breed) = completion {
                let viewController = ImagePreviewModuleFactory().module(image: image, breed: breed)
                view?.present(viewController, animated: true)
            }
        }.store(in: &subscriptions)

        return view
    }

    private func favouriteDogsViewModule() -> FavouriteDogsViewController {
        let view = FavouriteDogsModuleFactory().module()

        view.completion.sink { [weak view] completion in
            if case .openPreview(let image, let breed) = completion {
                let viewController = ImagePreviewModuleFactory().module(image: image, breed: breed)
                view?.present(viewController, animated: true)
            }
        }.store(in: &subscriptions)

        return view
    }
}
