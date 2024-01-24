import Foundation
import Combine

class DogsViewModel {
    @Published var model: [DogModel] = []
}

// MARK: - Fetch

extension DogsViewModel {
    func fetch() async {
        guard let dogModels = await RandomDogs(number: 50).fetch() else {
            return
        }
        model = dogModels
    }

    func fetchNext() async {
        guard let dogModels = await RandomDogs(number: 50).fetch() else {
            return
        }
        model += dogModels
    }
}

// MARK: - Favourite

extension DogsViewModel {
    func addFavourite(dogModel: DogModel) {
        FavouriteDogs.shared.addDog(imageUrl: dogModel.imageUrl)
        DispatchQueue.global(qos: .background).async {
            FavouriteDogs.shared.save()
        }
    }

    func removeFavourite(dogModel: DogModel) {
        FavouriteDogs.shared.removeDog(imageUrl: dogModel.imageUrl)
        DispatchQueue.global(qos: .background).async {
            FavouriteDogs.shared.save()
        }
    }

    func favourited(dogModel: DogModel) -> Bool {
        FavouriteDogs.shared.existsDog(imageUrl: dogModel.imageUrl)
    }
}
