import SwiftUI

struct EnhancedFeaturedCollectionView: View {
    let products: [Product]
    @State private var animationID = UUID()
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 20) {
            ForEach(products.indices, id: \.self) { index in
                EnhancedFeaturedProductItemView(
                    product: products[index],
                    initialDelay: Double.random(in: 0...2)
                )
                .id("product_\(products[index].id)_\(index)") // Unique ID to prevent interference
            }
        }
        .animation(.none, value: animationID) // Use stable value
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
    }
}

struct EnhancedFeaturedProductItemView: View {
    let product: Product
    let initialDelay: Double
    
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    @State private var isImageChanging = false
    @State private var isFavorite = false
    @State private var favoriteScale: CGFloat = 1.0
    
    private let imageCycleInterval: TimeInterval = 3.0
    
    var body: some View {
        Button(action: {
            handleProductTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    // Enhanced Image Container with Card Elevation
                    ZStack {
                        if product.images.indices.contains(currentImageIndex) {
                            CachedAsyncImage(
                                url: product.images[currentImageIndex],
                                contentMode: .fill,
                                height: 160,
                                cornerRadius: 12
                            )
                            .opacity(isImageChanging ? 0 : 1)
                            .scaleEffect(isImageChanging ? 1.05 : 1)
                        } else {
                            SkeletonShimmerView()
                                .frame(height: 160)
                                .cornerRadius(12)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                    )
                            .animation(.easeInOut(duration: 0.6), value: isImageChanging)
                            .animation(.easeInOut(duration: 0.6), value: currentImageIndex)
                    .onAppear {
                        startImageCycling()
                    }
                    .onDisappear {
                        stopImageCycling()
                    }
                    
                    // Enhanced Gradient Overlay for better text readability
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.clear, location: 0.5),
                            .init(color: Color.black.opacity(0.1), location: 0.8),
                            .init(color: Color.black.opacity(0.3), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .cornerRadius(12)
                    
                    // Enhanced Favorite Button with Micro-animation
                    Button(action: {
                        handleFavoriteTap()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(
                                isFavorite ?
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .pink]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .white]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.system(size: 16, weight: .medium))
                            .scaleEffect(favoriteScale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: favoriteScale)
                            .animation(.easeInOut(duration: 0.2), value: isFavorite)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(12)
                    
                    // Enhanced Image indicator dots
                    if product.images.count > 1 {
                        VStack {
                            Spacer()
                            HStack(spacing: 6) {
                                ForEach(0..<min(product.images.count, 5), id: \.self) { index in
                                    Circle()
                                        .fill(
                                            currentImageIndex == index ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppConstants.Colors.primary,
                                                    AppConstants.Colors.primary.opacity(0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: currentImageIndex == index ? 8 : 6,
                                               height: currentImageIndex == index ? 8 : 6)
                                        .animation(.easeInOut(duration: 0.3), value: currentImageIndex)
                                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Enhanced Product Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.custom(AppConstants.Fonts.inter, size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("₹ \(String(format: "%.0f", product.price))")
                        .font(.custom(AppConstants.Fonts.inter, size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppConstants.Colors.primary,
                                    AppConstants.Colors.primary.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(EnhancedProductButtonStyle())
    }
    
    private func startImageCycling() {
        guard product.images.count > 1 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            timer = Timer.scheduledTimer(withTimeInterval: imageCycleInterval, repeats: true) { _ in
                // Smooth transition without wrapper animation
                currentImageIndex = (currentImageIndex + 1) % product.images.count
            }
        }
    }
    
    private func stopImageCycling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleProductTap() {
        print("Product tapped: \(product.name)")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func handleFavoriteTap() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isFavorite.toggle()
            favoriteScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                favoriteScale = 1.0
            }
        }
        
        print("Favorite tapped for: \(product.name)")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: isFavorite ? .medium : .light)
        impactFeedback.impactOccurred()
    }
}

struct EnhancedProductButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
