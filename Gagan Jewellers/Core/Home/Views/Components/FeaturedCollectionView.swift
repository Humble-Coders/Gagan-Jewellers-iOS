import SwiftUI

struct FeaturedCollectionView: View {
    let products: [Product]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Collection")
                    .font(.custom(AppConstants.Fonts.inter, size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.text)
                
                Spacer()
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 16) {
                ForEach(products) { product in
                    FeaturedProductItemView(product: product)
                }
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        }
    }
}

struct FeaturedProductItemView: View {
    let product: Product
    
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    @State private var isImageChanging = false
    
    private let imageCycleInterval: TimeInterval = 3.0
    
    var body: some View {
        Button(action: {
            handleProductTap()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    // Image with cycling animation
                    ZStack {
                        if product.images.indices.contains(currentImageIndex) {
                            CachedAsyncImage(
                                url: product.images[currentImageIndex],
                                contentMode: .fill,
                                height: 150,
                                cornerRadius: AppConstants.Layout.cornerRadius
                            )
                            .opacity(isImageChanging ? 0 : 1)
                            .scaleEffect(isImageChanging ? 1.05 : 1)
                            .animation(.easeInOut(duration: 0.6), value: isImageChanging)
                            .animation(.easeInOut(duration: 0.6), value: currentImageIndex)
                        }
                    }
                    .onAppear {
                        startImageCycling()
                    }
                    .onDisappear {
                        stopImageCycling()
                    }
                    
                    // Favorite Button
                    Button(action: {
                        handleFavoriteTap()
                    }) {
                        Image(systemName: "heart")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(8)
                    
                    // Image indicator dots (if multiple images)
                    if product.images.count > 1 {
                        VStack {
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(0..<min(product.images.count, 5), id: \.self) { index in
                                    Circle()
                                        .fill(currentImageIndex == index ? Color.white : Color.white.opacity(0.5))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.custom(AppConstants.Fonts.inter, size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.text)
                        .lineLimit(2)
                    
                    Text("₹ \(String(format: "%.0f", product.price))")
                        .font(.custom(AppConstants.Fonts.inter, size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(AppConstants.Colors.primary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func startImageCycling() {
        guard product.images.count > 1 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: imageCycleInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isImageChanging = true
            }
            
            // Change image after brief animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentImageIndex = (currentImageIndex + 1) % product.images.count
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    isImageChanging = false
                }
            }
        }
    }
    
    private func stopImageCycling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleProductTap() {
        print("Product tapped: \(product.name)")
        // TODO: Navigate to product detail
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func handleFavoriteTap() {
        print("Favorite tapped for: \(product.name)")
        // TODO: Toggle favorite status
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}
