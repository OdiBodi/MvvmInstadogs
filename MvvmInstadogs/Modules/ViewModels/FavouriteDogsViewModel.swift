import Foundation
import Combine

class FavouriteDogsViewModel {
    @Published var model: [DogModel] = []
}

// MARK: - Fetch

extension FavouriteDogsViewModel {
    func fetch() {
        model = FavouriteDogs.shared.dogs.map { DogModel(imageUrl: $0.imageUrl) }
    }
}

// MARK: - Favourite

extension FavouriteDogsViewModel {
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
