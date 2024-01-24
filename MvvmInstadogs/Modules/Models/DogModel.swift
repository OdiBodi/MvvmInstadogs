struct DogModel: Equatable {
    let imageUrl: String
}

// MARK: - Helpers

extension DogModel {
    var breed: String {
        let components = imageUrl.components(separatedBy: "/")
        let index = components.count - 2
        return components[index]
    }
}
