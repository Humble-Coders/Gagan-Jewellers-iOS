import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var carouselItems: [CarouselItem] = []
    @Published var categories: [Category] = []
    @Published var featuredProducts: [Product] = []
    @Published var themedCollections: [ThemedCollection] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                async let carouselTask = firebaseService.fetchCarouselItems()
                async let categoriesTask = firebaseService.fetchCategories()
                async let featuredTask = firebaseService.fetchFeaturedProducts()
                async let collectionsTask = firebaseService.fetchThemedCollections()
                
                let (carousel, categories, featured, collections) = try await (
                    carouselTask, categoriesTask, featuredTask, collectionsTask
                )
                
                self.carouselItems = carousel
                self.categories = categories
                self.featuredProducts = featured
                self.themedCollections = collections
                self.isLoading = false
                
                // Debug: Print URLs being loaded
                print("🖼️ Carousel URLs:")
                carousel.forEach { item in
                    print("   \(item.title): \(item.imageUrl)")
                }
                
                print("🖼️ Collections URLs:")
                collections.forEach { collection in
                    print("   \(collection.name): \(collection.imageUrl)")
                }
                
                // Preload important images for better performance
                await preloadCriticalImages(
                    carousel: carousel,
                    categories: categories,
                    featured: featured
                )
                
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    private func preloadCriticalImages(
        carousel: [CarouselItem],
        categories: [Category],
        featured: [Product]
    ) async {
        var urlsToPreload: [String] = []
        
        // Add carousel images (highest priority)
        urlsToPreload.append(contentsOf: carousel.map { $0.imageUrl })
        
        // Add category images (medium priority)
        urlsToPreload.append(contentsOf: categories.prefix(8).map { $0.imageUrl })
        
        // Add featured product images (lower priority)
        urlsToPreload.append(contentsOf: featured.prefix(4).compactMap { $0.images.first })
        
        // Preload in background
        ImageCacheManager.shared.preloadImages(urls: urlsToPreload)
    }
    
    func refreshData() {
        loadData()
    }
}
