import Foundation

// MARK: - Carousel Item
struct CarouselItem: Identifiable, Codable {
    let id: String
    let imageUrl: String
    let title: String
    let subtitle: String
    let buttonText: String
    let actionTarget: String
    let actionType: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "imageUrl"
        case title
        case subtitle
        case buttonText = "buttonText"
        case actionTarget = "actionTarget"
        case actionType = "actionType"
    }
}

// MARK: - Category
struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let hasGenderVariants: Bool
    let imageUrl: String
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case hasGenderVariants = "has_gender_variants"
        case imageUrl = "image_url"
        case order
    }
}

// MARK: - Product
struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let price: Double
    let images: [String]
    let description: String
    let categoryId: String
    let materialId: String?
    let materialType: String?
    let gender: String?
    let available: Bool?
    let featured: Bool?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case images
        case description
        case categoryId = "category_id"
        case materialId = "material_id"
        case materialType = "material_type"
        case gender
        case available
        case featured
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        images = try container.decode([String].self, forKey: .images)
        description = try container.decode(String.self, forKey: .description)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        
        // Optional fields with defaults
        materialId = try? container.decode(String.self, forKey: .materialId)
        materialType = try? container.decode(String.self, forKey: .materialType)
        gender = try? container.decode(String.self, forKey: .gender)
        available = try? container.decode(Bool.self, forKey: .available)
        featured = try? container.decode(Bool.self, forKey: .featured)
        
        // Handle timestamp conversion
        if let timestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            createdAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(images, forKey: .images)
        try container.encode(description, forKey: .description)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(materialId, forKey: .materialId)
        try container.encodeIfPresent(materialType, forKey: .materialType)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(available, forKey: .available)
        try container.encodeIfPresent(featured, forKey: .featured)
        
        if let createdAt = createdAt {
            try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
        }
    }
}

// MARK: - Themed Collection
struct ThemedCollection: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String
    let order: Int
    let featured: Bool
    let productIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "imageUrl"
        case order
        case featured
        case productIds
    }
}

// MARK: - Material (Additional model for materials collection)
struct Material: Identifiable, Codable {
    let id: String
    let name: String
    let type: String
    let description: String?
    let purity: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case description
        case purity
    }
}
