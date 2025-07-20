import Foundation
import FirebaseFirestore
import Combine

class FirebaseService: ObservableObject {
    
    private let db = Firestore.firestore()
    
    // MARK: - Carousel Items
    func fetchCarouselItems() async throws -> [CarouselItem] {
        let snapshot = try await db.collection(AppConstants.Collections.carouselItems)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            // Clean up image URL by removing any extra characters
            if let imageUrl = data["imageUrl"] as? String {
                let cleanedUrl = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                data["imageUrl"] = cleanedUrl
                print("🧹 Cleaned carousel URL: \(cleanedUrl)")
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(CarouselItem.self, from: jsonData)
            } catch {
                print("Error decoding carousel item: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Categories
    func fetchCategories() async throws -> [Category] {
        let snapshot = try await db.collection(AppConstants.Collections.categories)
            .order(by: "order")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Category.self, from: jsonData)
            } catch {
                print("Error decoding category: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Featured Products
    func fetchFeaturedProducts() async throws -> [Product] {
        // First, get the featured product IDs from featured_products/featured_list
        let featuredDoc = try await db.collection(AppConstants.Collections.featuredProducts)
            .document("featured_list")
            .getDocument()
        
        guard featuredDoc.exists,
              let featuredData = featuredDoc.data(),
              let productIds = featuredData["product_ids"] as? [String],
              !productIds.isEmpty else {
            print("❌ No featured product IDs found")
            return []
        }
        
        print("🔍 Found \(productIds.count) featured product IDs: \(productIds)")
        
        // Fetch products with matching IDs
        // Firestore has a limit of 10 items for 'in' queries, so we'll batch them
        let batchSize = 10
        var allProducts: [Product] = []
        
        for i in stride(from: 0, to: productIds.count, by: batchSize) {
            let endIndex = min(i + batchSize, productIds.count)
            let batch = Array(productIds[i..<endIndex])
            
            let snapshot = try await db.collection(AppConstants.Collections.products)
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments()
            
            let batchProducts = snapshot.documents.compactMap { document -> Product? in
                var data = document.data()
                data["id"] = document.documentID
                
                // Convert Firestore Timestamp to Double for Date conversion
                if let timestamp = data["created_at"] as? Timestamp {
                    data["created_at"] = timestamp.seconds
                }
                
                // Debug: Print the data structure for problematic products
                print("🔍 Product \(document.documentID) fields: \(data.keys.sorted())")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let product = try JSONDecoder().decode(Product.self, from: jsonData)
                    print("✅ Successfully decoded product: \(product.name)")
                    return product
                } catch {
                    print("❌ Error decoding product \(document.documentID): \(error)")
                    
                    // Try to provide more helpful error information
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("   Missing required field: \(key.stringValue)")
                            print("   Available fields: \(data.keys.sorted())")
                        case .typeMismatch(let type, let context):
                            print("   Type mismatch for \(context.codingPath): expected \(type)")
                        case .valueNotFound(let type, let context):
                            print("   Value not found for \(context.codingPath): expected \(type)")
                        default:
                            print("   Decoding error: \(decodingError)")
                        }
                    }
                    return nil
                }
            }
            
            allProducts.append(contentsOf: batchProducts)
        }
        
        // Sort products to match the order in product_ids array
        let sortedProducts = productIds.compactMap { productId in
            allProducts.first { $0.id == productId }
        }
        
        print("✅ Successfully fetched \(sortedProducts.count) featured products")
        return sortedProducts
    }
    
    // MARK: - All Products
    func fetchProducts(limit: Int = 50) async throws -> [Product] {
        let snapshot = try await db.collection(AppConstants.Collections.products)
            .whereField("available", isEqualTo: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            // Convert Firestore Timestamp to Double for Date conversion
            if let timestamp = data["created_at"] as? Timestamp {
                data["created_at"] = timestamp.seconds
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Product.self, from: jsonData)
            } catch {
                print("Error decoding product: \(error)")
                return nil
            }
        }
    }
    
    // Add these methods to your existing FirebaseService class in FirebaseServices.swift

    // MARK: - Category Products
    func fetchProductsByCategory(categoryId: String) async throws -> [Product] {
        // First get the product IDs from category_products collection
        let categoryProductsDoc = try await db.collection("category_products")
            .document(categoryId)
            .getDocument()
        
        guard categoryProductsDoc.exists,
              let categoryData = categoryProductsDoc.data(),
              let productIds = categoryData["product_ids"] as? [String],
              !productIds.isEmpty else {
            print("❌ No product IDs found for category: \(categoryId)")
            return []
        }
        
        print("🔍 Found \(productIds.count) product IDs for category \(categoryId)")
        
        // Fetch products with matching IDs (batch processing for Firestore 'in' limit)
        let batchSize = 10
        var allProducts: [Product] = []
        
        for i in stride(from: 0, to: productIds.count, by: batchSize) {
            let endIndex = min(i + batchSize, productIds.count)
            let batch = Array(productIds[i..<endIndex])
            
            let snapshot = try await db.collection(AppConstants.Collections.products)
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments()
            
            let batchProducts = snapshot.documents.compactMap { document -> Product? in
                var data = document.data()
                data["id"] = document.documentID
                
                // Convert Firestore Timestamp to Double for Date conversion
                if let timestamp = data["created_at"] as? Timestamp {
                    data["created_at"] = timestamp.seconds
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let product = try JSONDecoder().decode(Product.self, from: jsonData)
                    return product
                } catch {
                    print("❌ Error decoding product \(document.documentID): \(error)")
                    return nil
                }
            }
            
            allProducts.append(contentsOf: batchProducts)
        }
        
        // Sort products to match the order in product_ids array
        let sortedProducts = productIds.compactMap { productId in
            allProducts.first { $0.id == productId }
        }
        
        print("✅ Successfully fetched \(sortedProducts.count) products for category")
        return sortedProducts
    }

    // MARK: - Materials
    func fetchMaterials() async throws -> [Material] {
        let snapshot = try await db.collection(AppConstants.Collections.materials)
            .getDocuments()
        
        print("🔍 Found \(snapshot.documents.count) material documents")
        
        return snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            // Debug: Print material data structure
            print("📋 Material \(document.documentID): \(data)")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let material = try JSONDecoder().decode(Material.self, from: jsonData)
                print("✅ Successfully decoded material: \(material.name) with types: \(material.types)")
                return material
            } catch {
                print("❌ Error decoding material \(document.documentID): \(error)")
                
                // Try to provide more helpful error information
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   Missing required field: \(key.stringValue)")
                        print("   Available fields: \(data.keys.sorted())")
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch for \(context.codingPath): expected \(type)")
                    case .valueNotFound(let type, let context):
                        print("   Value not found for \(context.codingPath): expected \(type)")
                    default:
                        print("   Decoding error: \(decodingError)")
                    }
                }
                return nil
            }
        }
    }
    
    // MARK: - Themed Collections
    func fetchThemedCollections() async throws -> [ThemedCollection] {
        let snapshot = try await db.collection(AppConstants.Collections.themedCollections)
            .order(by: "order")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(ThemedCollection.self, from: jsonData)
            } catch {
                print("Error decoding themed collection: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Products by Collection
    func fetchProductsByCollection(collectionId: String) async throws -> [Product] {
        // First get the collection to find associated products
        let collectionDoc = try await db.collection(AppConstants.Collections.themedCollections)
            .document(collectionId)
            .getDocument()
        
        guard let collectionData = collectionDoc.data(),
              let productIds = collectionData["productIds"] as? [String] else {
            return []
        }
        
        // Fetch products with matching IDs
        if productIds.isEmpty {
            return []
        }
        
        let snapshot = try await db.collection(AppConstants.Collections.products)
            .whereField(FieldPath.documentID(), in: productIds)
            .whereField("available", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            // Convert Firestore Timestamp to Double for Date conversion
            if let timestamp = data["created_at"] as? Timestamp {
                data["created_at"] = timestamp.seconds
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Product.self, from: jsonData)
            } catch {
                print("Error decoding collection product: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Debug: List Storage Contents
    func debugStorageContents() {
        print("🔍 Checking Firebase Storage contents...")
        // Note: This would require Firebase Storage SDK
        // For now, manually check Firebase Console → Storage
        // Look for folders: carousel/, products/, categories/, collections/
    }
    
    // MARK: - Search Products
    func searchProducts(query: String) async throws -> [Product] {
        let snapshot = try await db.collection(AppConstants.Collections.products)
            .whereField("available", isEqualTo: true)
            .getDocuments()
        
        let allProducts = snapshot.documents.compactMap { document -> Product? in
            var data = document.data()
            data["id"] = document.documentID
            
            // Convert Firestore Timestamp to Double for Date conversion
            if let timestamp = data["created_at"] as? Timestamp {
                data["created_at"] = timestamp.seconds
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Product.self, from: jsonData)
            } catch {
                print("Error decoding search product: \(error)")
                return nil
            }
        }
        
        // Filter products based on search query
        let lowercaseQuery = query.lowercased()
        return allProducts.filter { product in
            product.name.lowercased().contains(lowercaseQuery) ||
            product.description.lowercased().contains(lowercaseQuery) ||
            (product.materialType?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
}
