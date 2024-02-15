import UIKit

class ImagesDownloader<Id: Hashable> {
    private let operationsQueue = OperationQueue()
    private var operations: [Id: Operation] = [:]
}

// MARK: - Download

extension ImagesDownloader {
    func downloadImage(id: Id, url: String, completion: @escaping (UIImage) -> Void) {
        if let currentOperation = operations[id] {
            currentOperation.cancel()
            operations.removeValue(forKey: id)
        }

        let operation = ImageDownloadOperation(url: url)
        let operationHash = operation.hash

        operation.completion = { [weak self, operationHash] image in
            guard let image else {
                if self?.operations[id]?.hash == operationHash {
                    self?.operations.removeValue(forKey: id)
                }
                return
            }

            DispatchQueue.main.async {
                if self?.operations[id]?.hash != operationHash {
                    return
                }
                self?.operations.removeValue(forKey: id)
                completion(image)
            }
        }

        operations[id] = operation
        operationsQueue.addOperation(operation)
    }
}
