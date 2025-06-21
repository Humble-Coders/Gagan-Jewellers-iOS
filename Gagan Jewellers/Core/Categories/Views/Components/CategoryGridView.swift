import SwiftUI

struct CategoryGridView: View {
    let categories: [Category]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { category in
                CategoryCardView(category: category)
            }
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
    }
}

struct CategoryCardView: View {
    let category: Category
    
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
                
                // Gradient Overlay for better text readability
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
                
                // Category Name - Bottom Left
                Text(category.name)
                    .font(.custom(AppConstants.Fonts.inter, size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                    .padding(.leading, 16)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
