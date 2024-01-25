import Foundation

class FavouriteDogs {
    static let shared = FavouriteDogs()

    private init() { }

    var dogs: [FavouriteDogModel] = []
}

// MARK: - Operations

extension FavouriteDogs {
    func load() -> Bool {
        guard let url = url() else {
            return false
        }

        do {
            let data = try Data(contentsOf: url)
            let model = try JSONDecoder().decode(FavouriteDogsModel.self, from: data)
            dogs = model.dogs
            return true
        } catch {
            print("FavouriteDogs: load error: \(error)")
        }

        return false
    }

    func save() -> Bool {
        do {
            let model = FavouriteDogsModel(dogs: dogs)
            let data = try JSONEncoder().encode(model)

            guard let url = url() else {
                return false
            }

            try data.write(to: url)
        } catch {
            print("FavouriteDogs: save error: \(error)")
        }

        return true
    }
}

// MARK: - Url

extension FavouriteDogs {
    private func url() -> URL? {
        do {
            let cachesUrl = try FileManager.default.url(for: .cachesDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true)
            return cachesUrl.appendingPathComponent("favourite")
        } catch {
            print("FavouriteDogs: url error: \(error.localizedDescription)")
        }
        return nil
    }
}

// MARK: - Helpers

extension FavouriteDogs {
    func addDog(imageUrl: String) {
        guard !existsDog(imageUrl: imageUrl) else {
            return
        }
        let model = FavouriteDogModel(imageUrl: imageUrl)
        dogs.append(model)
    }

    func removeDog(imageUrl: String) {
        dogs.removeAll { $0.imageUrl == imageUrl }
    }

    func existsDog(imageUrl: String) -> Bool {
        return dogs.contains { $0.imageUrl == imageUrl }
    }
}
