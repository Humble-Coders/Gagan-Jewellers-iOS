import SwiftUI

struct AppConstants {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "C4A661")
        static let background = Color.white
        static let text = Color.black
        static let textSecondary = Color.gray
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let inter = "Inter"
    }
    
    // MARK: - Firestore Collections
    struct Collections {
        static let carouselItems = "carousel_items"
        static let categories = "categories"
        static let featuredProducts = "featured_products"
        static let products = "products"
        static let themedCollections = "themed_collections"
        static let materials = "materials"
        static let users = "users"
        static let categoryProducts = "category_products"
    }
    
    // MARK: - Layout
    struct Layout {
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let cornerRadius: CGFloat = 8
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
