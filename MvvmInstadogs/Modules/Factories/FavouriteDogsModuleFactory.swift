struct FavouriteDogsModuleFactory {
    func module() -> FavouriteDogsViewController {
        let viewModel = FavouriteDogsViewModel()
        let view = FavouriteDogsViewController()

        view.initialize(viewModel: viewModel)

        return view
    }
}
