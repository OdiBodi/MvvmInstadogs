import UIKit

class ImagePreviewViewController: UIViewController {
    private lazy var topPlaceholderView = initializeTopPlaceholderView()
    private lazy var backgroundImage = initializeBackgroundImage()
    private lazy var breedLabel = initializeBreedLabel()
}

// MARK: - Life cycle

extension ImagePreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Initializators

extension ImagePreviewViewController {
    func initialize(viewModel: ImagePreviewViewModel) {
        let model = viewModel.model
        backgroundImage.image = model.image
        breedLabel.text = model.breed
    }
}

// MARK: - Configurators

extension ImagePreviewViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
}

// MARK: - Subviews

extension ImagePreviewViewController {
    private func initializeTopPlaceholderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 2.5
        return view
    }

    private func initializeBackgroundImage() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemBackground
        return view
    }

    private func initializeBreedLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
        label.backgroundColor = .systemBackground
        return label
    }

    private func addSubviews() {
        view.addSubview(topPlaceholderView)
        view.addSubview(backgroundImage)
        view.addSubview(breedLabel)
    }

    private func updateSubviewsConstraints() {
        topPlaceholderView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(20)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(50)
            maker.height.equalTo(5)
        }
        backgroundImage.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalToSuperview().inset(150)
            maker.bottom.equalToSuperview().inset(150)
        }
        breedLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview().inset(16)
            maker.top.equalTo(backgroundImage.snp.bottom)
            maker.height.equalTo(50)
        }
    }
}
