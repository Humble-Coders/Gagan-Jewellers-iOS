import SwiftUI

struct CategoryGridView: View {
    let categories: [Category]
    let getProductCount: (String) -> Int
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { category in
                CategoryCardView(
                    category: category,
                    productCount: getProductCount(category.id)
                )
            }
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
    }
}

struct CategoryCardView: View {
    let category: Category
    let productCount: Int
    
    var body: some View {
        Button(action: {
            handleCategoryTap()
        }) {
            ZStack(alignment: .bottomLeading) {
                // Background Image
                CachedAsyncImage(
                    url: category.imageUrl,
                    contentMode: .fill,
                    height: 180,
                    cornerRadius: 12
                )
                
                // Gradient Overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .clear,
                        .black.opacity(0.4),
                        .black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(12)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.custom(AppConstants.Fonts.inter, size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(productCount)+ Items")
                        .font(.custom(AppConstants.Fonts.inter, size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(16)
            }
        }
        .buttonStyle(CategoryButtonStyle())
    }
    
    private func handleCategoryTap() {
        print("Category tapped: \(category.name)")
        // TODO: Navigate to category products
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}