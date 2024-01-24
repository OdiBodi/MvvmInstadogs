import UIKit
import Combine

class DogsCollectionView: UIView,
                          UICollectionViewDataSource,
                          UICollectionViewDelegate,
                          UICollectionViewDelegateFlowLayout {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControl), for: .valueChanged)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.register(DogViewCell.self, forCellWithReuseIdentifier: "DogViewCell")
        view.backgroundColor = .systemBackground
        view.isScrollEnabled = true
        view.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        view.refreshControl = refreshControl

        return view
    }()

    var model: [DogModel]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.update()
            }
        }
    }

    var favouritedHandler: ((DogModel) -> Bool)?

    private var newDataFetchSubject = PassthroughSubject<UIRefreshControl, Never>()
    private var nextDataFetchSubject = PassthroughSubject<Void, Never>()
    private var openPreviewSubject = PassthroughSubject<(image: UIImage, breed: String), Never>()
    private var addFavouriteSubject = PassthroughSubject<DogModel, Never>()
    private var removeFavouriteSubject = PassthroughSubject<DogModel, Never>()

    private let imagesDownloader = ImagesDownloader<Int>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Publishers

extension DogsCollectionView {
    var newDataFetch: AnyPublisher<UIRefreshControl, Never> {
        newDataFetchSubject.eraseToAnyPublisher()
    }

    var nextDataFetch: AnyPublisher<Void, Never> {
        nextDataFetchSubject.eraseToAnyPublisher()
    }

    var openPreview: AnyPublisher<(image: UIImage, breed: String), Never> {
        openPreviewSubject.eraseToAnyPublisher()
    }

    var addFavourite: AnyPublisher<DogModel, Never> {
        addFavouriteSubject.eraseToAnyPublisher()
    }

    var removeFavourite: AnyPublisher<DogModel, Never> {
        removeFavouriteSubject.eraseToAnyPublisher()
    }
}

// MARK: - Life cycle

extension DogsCollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Subviews

extension DogsCollectionView {
    private func addSubviews() {
        addSubview(collectionView)
    }

    private func updateSubviewsConstraints() {
        collectionView.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
    }
}

// MARK: - Utilites

extension DogsCollectionView {
    private func cellSize() -> CGFloat {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let contentInset = collectionView.contentInset
        let width = bounds.width
        let inset = contentInset.left + contentInset.right
        let spacing = layout.minimumInteritemSpacing * (3 - 1)
        let size = (width - inset - spacing) / 3
        return size
    }

    func update() {
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}

// MARK: - Helpers

extension DogsCollectionView {
    func scrollToTop() {
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension DogsCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DogViewCell",
                                                      for: indexPath) as! DogViewCell

        let index = indexPath.item
        guard let model = model?[index] else {
            return cell
        }

        cell.favouritedChanged = { [weak self] value in
            value ? self?.addFavouriteSubject.send(model) : self?.removeFavouriteSubject.send(model)
        }

        let id = cell.hash
        let url = model.imageUrl
        imagesDownloader.downloadImage(id: id, url: url) { [weak self, weak cell] image in
            let breed = model.breed
            let favourited = self?.favouritedHandler?(model) ?? false
            cell?.initialize(image: image, breed: breed, favourited: favourited)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension DogsCollectionView {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let currentItem = indexPath.item
        let lastItem = collectionView.numberOfItems(inSection: 0) - 1

        guard currentItem == lastItem else {
            return
        }

        nextDataFetchSubject.send()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DogViewCell else {
            return
        }

        guard let image = cell.image else {
            return
        }

        openPreviewSubject.send((image: image, breed: cell.breed))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DogsCollectionView {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = cellSize()
        return CGSize(width: cellSize, height: cellSize)
    }
}

// MARK: - Callbacks

extension DogsCollectionView {
    @objc func onRefreshControl() {
        guard let refreshControl = collectionView.refreshControl else {
            return
        }
        newDataFetchSubject.send(refreshControl)
    }
}
