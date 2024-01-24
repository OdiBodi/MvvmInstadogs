struct RandomDogsModel: Codable {
    let imageUrls: [String]
}

// MARK: - Coding keys

extension RandomDogsModel {
    enum CodingKeys: String, CodingKey {
        case imageUrls = "message"
    }
}

// MARK: - Converters

extension RandomDogsModel {
    var dogModels: [DogModel] {
        return imageUrls.map { DogModel(imageUrl: $0) }
    }
}
