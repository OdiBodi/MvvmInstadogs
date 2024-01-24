import UIKit
import Combine

class FavouriteDogsViewController: BaseCoordinatorModule<FavouriteDogsModuleCompletion, Never> {
    private lazy var dogsCollectionView: DogsCollectionView = {
        let view = DogsCollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.favouritedHandler = { [weak self] model in
            self?.viewModel?.favourited(dogModel: model) ?? false
        }
        view.newDataFetch.sink { [weak self] refreshControl in
            self?.viewModel?.fetch()
            RunLoop.main.perform {
                refreshControl.endRefreshing()
            }
        }.store(in: &subscriptions)
        view.openPreview.sink { [weak self] (image, breed) in
            self?.completionSubject.send(.openPreview(image: image, breed: breed))
        }.store(in: &subscriptions)
        view.addFavourite.sink { [weak self] model in
            self?.viewModel?.addFavourite(dogModel: model)
        }.store(in: &subscriptions)
        view.removeFavourite.sink { [weak self] model in
            self?.viewModel?.removeFavourite(dogModel: model)
        }.store(in: &subscriptions)

        return view
    }()

    private var viewModel: FavouriteDogsViewModel?
    private var subscriptions = Set<AnyCancellable>()
}

// MARK: Life cycle

extension FavouriteDogsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSubviewsConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.fetch()
    }
}

// MARK: - Initializators

extension FavouriteDogsViewController {
    func initialize(viewModel: FavouriteDogsViewModel) {
        self.viewModel = viewModel
        self.viewModel?.$model.sink { [weak self] model in
            guard self?.viewModel?.model != model else {
                return
            }
            self?.dogsCollectionView.model = model
        }.store(in: &subscriptions)
    }
}

// MARK: - Configurators

extension FavouriteDogsViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
    }

    func configureTabBarItem() {
        let image = UIImage(systemName: "star.fill")
        tabBarItem = UITabBarItem(title: "Favourite", image: image, tag: 1)
    }
}

// MARK: - Subviews

extension FavouriteDogsViewController {
    private func addSubviews() {
        view.addSubview(dogsCollectionView)
    }

    private func updateSubviewsConstraints() {
        dogsCollectionView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - Scrolling

extension FavouriteDogsViewController {
    func scrollToTop() {
        dogsCollectionView.scrollToTop()
    }
}
