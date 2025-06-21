import Foundation
import Combine

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var themedCollections: [ThemedCollection] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let firebaseService = FirebaseService()
    
    // Use cached data from HomeViewModel if available
    func loadData(cachedCategories: [Category]? = nil, cachedCollections: [ThemedCollection]? = nil) {
        if let cached = cachedCategories, !cached.isEmpty,
           let cachedCol = cachedCollections, !cachedCol.isEmpty {
            // Use cached data to avoid Firebase reads
            self.categories = cached
            self.themedCollections = cachedCol
            print("📱 Using cached data for Categories screen")
            return
        }
        
        // Fallback: fetch from Firebase if no cached data
        isLoading = true
        error = nil
        
        Task {
            do {
                async let categoriesTask = firebaseService.fetchCategories()
                async let collectionsTask = firebaseService.fetchThemedCollections()
                
                let (categories, collections) = try await (categoriesTask, collectionsTask)
                
                self.categories = categories
                self.themedCollections = collections
                self.isLoading = false
                
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
