import UIKit
import SnapKit

class DogViewCell: UICollectionViewCell {
    private lazy var backgroundImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()

    private lazy var favouriteImage: UIImageView = {
        let image = UIImage(systemName: "heart")
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.isHidden = true
        view.contentMode = .scaleAspectFill
        view.tintColor = .systemRed
        return view
    }()

    private lazy var breedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.layer.opacity = 0.7
        return label
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = .init(scaleX: 1.25, y: 1.25)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    var favourited: Bool = false {
        didSet {
            favouriteImage.image = favourited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
    }

    var favouritedChanged: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onFavouriteImageTapped))
        favouriteImage.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Model

extension DogViewCell {
    var image: UIImage? {
        backgroundImage.image
    }

    var breed: String {
        breedLabel.text ?? ""
    }
}

// MARK: - Life cycle

extension DogViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImage.image = nil
        breedLabel.isHidden = true
        favouriteImage.isHidden = true
        loadingIndicator.startAnimating()
    }
}

// MARK: Initializators

extension DogViewCell {
    func initialize(image: UIImage, breed: String, favourited: Bool) {
        backgroundImage.image = image

        breedLabel.text = breed.uppercased()
        breedLabel.isHidden = false

        self.favourited = favourited
        favouriteImage.isHidden = false

        loadingIndicator.stopAnimating()
    }
}

// MARK: - Subviews

extension DogViewCell {
    private func addSubviews() {
        contentView.addSubview(backgroundImage)
        contentView.addSubview(favouriteImage)
        contentView.addSubview(breedLabel)
        contentView.addSubview(loadingIndicator)
    }

    private func updateSubviewsConstraints() {
        backgroundImage.snp.updateConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        favouriteImage.snp.updateConstraints { maker in
            maker.top.equalToSuperview().inset(5)
            maker.right.equalToSuperview().inset(5)
            maker.width.equalTo(20)
            maker.height.equalTo(20)
        }
        breedLabel.snp.updateConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(20)
        }
        loadingIndicator.snp.updateConstraints { maker in
            maker.centerX.centerY.equalToSuperview()
        }
    }
}

// MARK: Callbacks

extension DogViewCell {
    @objc private func onFavouriteImageTapped() {
        favourited = !favourited
        favouritedChanged?(favourited)
    }
}
