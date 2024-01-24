import UIKit

class ImageDownloadOperation: Operation {
    private let url: String

    var completion: ((UIImage?) -> Void)?

    init(url: String) {
        self.url = url
        super.init()
    }

    init(url: String, completion: @escaping (UIImage?) -> Void) {
        self.url = url
        self.completion = completion
        super.init()
    }

    override func main() {
        guard !isCancelled else {
            return
        }

        guard let url = URL(string: url) else {
            return
        }

        let request = URLRequest(url: url)
        var image: UIImage?

        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            defer {
                self?.completion?(image)
            }

            if let error = error {
                print("ImageDownloadOperation: Download image error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return
            }

            guard let data = data else {
                return
            }

            image = UIImage(data: data)
        }

        dataTask.resume()
    }
}
