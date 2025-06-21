import SwiftUI
import Combine

class ImageCacheService: ObservableObject {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func loadImage(from url: String) -> AnyPublisher<UIImage?, Never> {
        guard let imageURL = URL(string: url) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        let cacheKey = NSString(string: url)
        
        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // Load from network
        return session.dataTaskPublisher(for: imageURL)
            .map { data, _ in
                UIImage(data: data)
            }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] image in
                if let image = image {
                    self?.cache.setObject(image, forKey: cacheKey)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
