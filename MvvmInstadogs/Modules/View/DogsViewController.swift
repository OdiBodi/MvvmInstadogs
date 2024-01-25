import Foundation
import UIKit
import Combine

class DogsViewController: BaseCoordinatorModule<DogsModuleCompletion, Never> {
    private lazy var dogsCollectionView: DogsCollectionView = {
        let view = DogsCollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.favouritedHandler = { [weak self] model in
            self?.viewModel?.favourited(dogModel: model) ?? false
        }
        view.newDataFetch.sink { refreshControl in
            Task { [weak self] in
                await self?.viewModel?.fetch()
                RunLoop.main.perform {
                    refreshControl.endRefreshing()
                }
            }
        }.store(in: &subscriptions)
        view.nextDataFetch.sink {
            Task.detached { [weak self] in
                await self?.viewModel?.fetchNext()
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

    private var viewModel: DogsViewModel?
    private var subscriptions = Set<AnyCancellable>()
}

// MARK: Life cycle

extension DogsViewController {
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

        if viewModel?.model.isEmpty ?? true {
            Task.detached { [weak self] in
                await self?.viewModel?.fetch()
            }
        } else {
            dogsCollectionView.update()
        }
    }
}

// MARK: - Initializators

extension DogsViewController {
    func initialize(viewModel: DogsViewModel) {
        self.viewModel = viewModel
        self.viewModel?.$model.sink { [weak self] model in
            guard self?.viewModel?.model != model else {
                return
            }
            self?.dogsCollectionView.model = model
        }.store(in: &subscriptions)

        configureTabBarItem()
    }
}

// MARK: - Configurators

extension DogsViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
    }

    private func configureTabBarItem() {
        let image = UIImage(systemName: "dog.fill")
        tabBarItem = UITabBarItem(title: "Dogs", image: image, tag: 0)
    }
}

// MARK: - Subviews

extension DogsViewController {
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

extension DogsViewController {
    func scrollToTop() {
        dogsCollectionView.scrollToTop()
    }
}
