import SwiftUI

struct FeaturedCollectionsGridView: View {
    let collections: [ThemedCollection]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Collections")
                .font(.custom(AppConstants.Fonts.inter, size: 20))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.text)
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            
            LazyVStack(spacing: 12) {
                ForEach(collections.prefix(3)) { collection in
                    FeaturedCollectionCardView(collection: collection)
                }
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        }
    }
}

struct FeaturedCollectionCardView: View {
    let collection: ThemedCollection
    
    var body: some View {
        Button(action: {
            handleCollectionTap()
        }) {
            ZStack(alignment: .leading) {
                // Background Image
                CachedAsyncImage(
                    url: collection.imageUrl,
                    contentMode: .fill,
                    height: 120,
                    cornerRadius: 12
                )
                
                // Subtle gradient overlay for text readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.3),
                        .clear,
                        .clear,
                        .black.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(12)
                
                // Collection Content
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.name)
                            .font(.custom(AppConstants.Fonts.inter, size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                    }
                    .padding(.leading, 20)
                    .padding(.vertical, 16)
                    
                    Spacer()
                    
                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                        .padding(.trailing, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .cornerRadius(12)
            .clipped()
        }
        .buttonStyle(CollectionButtonStyle())
    }
    
    private func handleCollectionTap() {
        print("Collection tapped: \(collection.name)")
        // TODO: Navigate to collection products
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

struct CollectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
