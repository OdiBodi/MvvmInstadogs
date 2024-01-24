import Foundation

struct RandomDogs {
    private let randomUrl = "https://dog.ceo/api/breeds/image/random"

    private let number: Int

    init(number: Int) {
        self.number = number
    }

    func fetch() async -> [DogModel]? {
        let resultRandomUrl = randomUrl + "/\(number)"

        guard let url = URL(string: resultRandomUrl) else {
            return nil
        }

        do {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            let dogsModel = try JSONDecoder().decode(RandomDogsModel.self, from: data)
            return dogsModel.dogModels
        } catch {
            print("RandomDogs: fetch error: \(error.localizedDescription)")
        }

        return nil
    }
}
