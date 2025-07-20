import Foundation
import Combine

@MainActor
class CategoryProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var materials: [Material] = []
    @Published var activeFilters: [String] = ["All"]
    @Published var isLoading = false
    @Published var error: String?
    
    // Filter and Sort states
    @Published var selectedMaterials: Set<String> = []
    @Published var selectedMaterialTypes: Set<String> = []
    @Published var selectedGender: String? = nil
    @Published var sortBy: SortOption = .none
    
    private let firebaseService = FirebaseService()
    
    enum SortOption: String, CaseIterable {
        case none = "None"
        case priceLowToHigh = "Price: Low to High"
        case priceHighToLow = "Price: High to Low"
        case weightLowToHigh = "Weight: Low to High"
        case weightHighToLow = "Weight: High to Low"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    func loadProducts(for categoryId: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let categoryProducts = try await firebaseService.fetchProductsByCategory(categoryId: categoryId)
                self.products = categoryProducts
                self.filteredProducts = categoryProducts
                self.isLoading = false
                
                // Reset filters when loading new category
                resetFilters()
                
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMaterials() {
        print("🔄 Starting to load materials...")
        Task {
            do {
                let materialsData = try await firebaseService.fetchMaterials()
                print("✅ Loaded \(materialsData.count) materials")
                self.materials = materialsData
                
                // Debug: Print each material
                for material in materialsData {
                    print("📋 Material: \(material.name) (ID: \(material.id)) - Types: \(material.types)")
                }
            } catch {
                print("❌ Error loading materials: \(error)")
                self.error = "Failed to load materials: \(error.localizedDescription)"
            }
        }
    }
    
    func applyFilters() {
        var filtered = products
        var currentFilters: [String] = []
        
        // Filter by materials (match document name with material_id)
        if !selectedMaterials.isEmpty {
            filtered = filtered.filter { product in
                guard let materialId = product.materialId else { return false }
                return selectedMaterials.contains(materialId)
            }
            currentFilters.append(contentsOf: selectedMaterials.compactMap { materialId in
                materials.first(where: { $0.id == materialId })?.name
            })
        }
        
        // Filter by material types (match with material_type field)
        if !selectedMaterialTypes.isEmpty {
            filtered = filtered.filter { product in
                guard let materialType = product.materialType else { return false }
                return selectedMaterialTypes.contains(materialType)
            }
            currentFilters.append(contentsOf: selectedMaterialTypes)
        }
        
        // Filter by gender
        if let gender = selectedGender, gender != "All" {
            filtered = filtered.filter { product in
                return product.gender?.lowercased() == gender.lowercased()
            }
            currentFilters.append(gender)
        }
        
        // Apply sorting
        switch sortBy {
        case .none:
            break
        case .priceLowToHigh:
            filtered.sort { $0.price < $1.price }
            currentFilters.append("Price ↑")
        case .priceHighToLow:
            filtered.sort { $0.price > $1.price }
            currentFilters.append("Price ↓")
        case .weightLowToHigh:
            filtered.sort { (product1, product2) in
                let weight1 = extractWeight(from: product1)
                let weight2 = extractWeight(from: product2)
                return weight1 < weight2
            }
            currentFilters.append("Weight ↑")
        case .weightHighToLow:
            filtered.sort { (product1, product2) in
                let weight1 = extractWeight(from: product1)
                let weight2 = extractWeight(from: product2)
                return weight1 > weight2
            }
            currentFilters.append("Weight ↓")
        }
        
        self.filteredProducts = filtered
        self.activeFilters = currentFilters.isEmpty ? ["All"] : currentFilters
    }
    
    func removeFilter(_ filter: String) {
        // Remove material filters
        if let material = materials.first(where: { $0.name == filter }) {
            selectedMaterials.remove(material.id)
        }
        
        // Remove material type filters
        selectedMaterialTypes.remove(filter)
        
        // Remove gender filter
        if filter == selectedGender {
            selectedGender = nil
        }
        
        // Remove sort filters
        if filter.contains("Price") || filter.contains("Weight") {
            sortBy = .none
        }
        
        applyFilters()
    }
    
    func resetFilters() {
        selectedMaterials.removeAll()
        selectedMaterialTypes.removeAll()
        selectedGender = nil
        sortBy = .none
        activeFilters = ["All"]
        filteredProducts = products
    }
    
    func getMaterialTypesForMaterial(_ materialId: String) -> [String] {
        return materials.first(where: { $0.id == materialId })?.types ?? []
    }
    
    private func extractWeight(from product: Product) -> Double {
        // Extract numeric weight from weight string (e.g., "24.6g" -> 24.6)
        guard let weightString = product.weight else { return 0.0 }
        
        let numbers = weightString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(numbers) ?? 0.0
    }
}

