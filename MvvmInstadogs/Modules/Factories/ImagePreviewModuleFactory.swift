import UIKit

struct ImagePreviewModuleFactory {
    func module(image: UIImage, breed: String) -> ImagePreviewViewController {
        let model = ImagePreviewModel(image: image, breed: breed)
        let view = ImagePreviewViewController()
        let viewModel = ImagePreviewViewModel(model: model)

        view.initialize(viewModel: viewModel)

        return view
    }
}
