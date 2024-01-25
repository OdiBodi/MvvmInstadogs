import Foundation

extension URLSession {
    func configure() {
        let cacheSizeMemory = 200 * 1024 * 1024
        let cacheSizeDisk = 200 * 1024 * 1024
        self.configuration.urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk)
    }
}
