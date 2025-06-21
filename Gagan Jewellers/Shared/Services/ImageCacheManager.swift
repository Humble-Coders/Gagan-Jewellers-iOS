import Foundation
import SDWebImage
import SDWebImageSwiftUI

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() {
        configureCache()
    }
    
    private func configureCache() {
        // Configure memory cache
        SDImageCache.shared.config.maxMemoryCost = 100 * 1024 * 1024 // 100MB
        SDImageCache.shared.config.maxMemoryCount = 50 // 50 images in memory
        
        // Configure disk cache
        SDImageCache.shared.config.maxDiskSize = 500 * 1024 * 1024 // 500MB
        SDImageCache.shared.config.maxDiskAge = 7 * 24 * 60 * 60 // 7 days
        
        // Configure download timeout
        SDWebImageDownloader.shared.config.downloadTimeout = 30.0
        
        // Enable disk cache
        SDImageCache.shared.config.shouldCacheImagesInMemory = true
        SDImageCache.shared.config.shouldUseWeakMemoryCache = true
        
        // Configure image formats
        SDImageCache.shared.config.diskCacheExpireType = .modificationDate
        
        print("✅ Image cache configured successfully")
        printCacheInfo()
    }
    
    func preloadImages(urls: [String]) {
        let prefetcher = SDWebImagePrefetcher.shared
        let imageUrls = urls.compactMap { URL(string: $0) }
        
        prefetcher.prefetchURLs(imageUrls) { finished, skipped in
            print("🚀 Preloaded \(finished) images, skipped \(skipped)")
        }
    }
    
    func clearCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk {
            print("🗑️ Cache cleared")
        }
    }
    
    func clearMemoryCache() {
        SDImageCache.shared.clearMemory()
        print("🧹 Memory cache cleared")
    }
    
    func getCacheSize(completion: @escaping (String) -> Void) {
        SDImageCache.shared.calculateSize { fileCount, totalSize in
            let sizeInMB = Double(totalSize) / (1024 * 1024)
            let sizeString = String(format: "%.2f MB (%d files)", sizeInMB, fileCount)
            completion(sizeString)
        }
    }
    
    func printCacheInfo() {
        getCacheSize { size in
            print("📊 Current cache size: \(size)")
        }
    }
    
    // Check if image exists in cache (simplified version)
    func isImageCached(url: String) -> Bool {
        guard let imageURL = URL(string: url) else { return false }
        let key = imageURL.absoluteString
        
        // Only check memory cache to avoid async issues
        return SDImageCache.shared.imageFromMemoryCache(forKey: key) != nil
    }
    
    // Get cache type for URL (simplified to avoid async issues)
    func getCacheType(for url: String, completion: @escaping (SDImageCacheType) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(.none)
            return
        }
        
        let key = imageURL.absoluteString
        
        // Check memory first
        if SDImageCache.shared.imageFromMemoryCache(forKey: key) != nil {
            completion(.memory)
            return
        }
        
        // For disk cache, use a simpler approach
        DispatchQueue.global(qos: .background).async {
            // Use the cache's queryCacheOperation instead
            SDImageCache.shared.queryCacheOperation(forKey: key) { image, data, cacheType in
                DispatchQueue.main.async {
                    if image != nil {
                        completion(cacheType)
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    // Optimized method to check multiple images cache status
    func checkCacheStatus(for urls: [String]) {
        for url in urls {
            getCacheType(for: url) { cacheType in
                let status: String
                switch cacheType {
                case .none:
                    status = "Not Cached"
                case .disk:
                    status = "Disk Cache"
                case .memory:
                    status = "Memory Cache"
                @unknown default:
                    status = "Unknown"
                }
                let fileName = URL(string: url)?.lastPathComponent ?? "unknown"
                print("📋 \(fileName): \(status)")
            }
        }
    }
    
    // Force cache an image
    func cacheImage(from url: String, completion: @escaping (Bool) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(false)
            return
        }
        
        SDWebImageDownloader.shared.downloadImage(with: imageURL) { image, data, error, finished in
            if let image = image, let data = data {
                SDImageCache.shared.store(
                    image,
                    imageData: data,
                    forKey: imageURL.absoluteString,
                    toDisk: true
                ) {
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    // Simple cache warming for critical images
    func warmCache(urls: [String]) {
        print("🔥 Warming cache for \(urls.count) images")
        for url in urls.prefix(5) { // Only warm first 5 to avoid overwhelming
            cacheImage(from: url) { success in
                if success {
                    print("✅ Cached: \(URL(string: url)?.lastPathComponent ?? "unknown")")
                }
            }
        }
    }
}
