struct DogsModuleFactory {
    func module() -> DogsViewController {
        let viewModel = DogsViewModel()
        let view = DogsViewController()

        view.initialize(viewModel: viewModel)

        return view
    }
}
