import SwiftUI

struct CategoryProductsView: View {
    let category: Category
    @StateObject private var viewModel = CategoryProductsViewModel()
    @State private var showingFilterSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                // Filter Tabs and Filter Button
                filterTabsSection
                
                // Content
                if viewModel.isLoading {
                    LoadingStateView(message: "Loading products...")
                } else if let error = viewModel.error {
                    ErrorStateView(message: error) {
                        viewModel.loadProducts(for: category.id)
                    }
                } else {
                    productsGridView
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSortSheet(
                viewModel: viewModel,
                isPresented: $showingFilterSheet
            )
        }
        .onAppear {
            viewModel.loadProducts(for: category.id)
            viewModel.loadMaterials()
        }
    }
    
    private var topBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppConstants.Colors.text)
            }
            .frame(width: 40, height: 40)
            
            Spacer()
            
            Text(category.name)
                .font(.custom(AppConstants.Fonts.inter, size: 20))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.primary)
            
            Spacer()
            
            Button(action: {
                // Haptic feedback for search
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // Search functionality
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(AppConstants.Colors.text)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        .padding(.vertical, 12)
        .background(AppConstants.Colors.background)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    private var filterTabsSection: some View {
        HStack {
            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.activeFilters, id: \.self) { filter in
                        FilterTabView(
                            title: filter,
                            isRemovable: filter != "All"
                        ) {
                            viewModel.removeFilter(filter)
                        }
                    }
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            }
            
            Spacer()
            
            // Filter & Sort Button
            Button(action: {
                // Haptic feedback for filter sheet
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                showingFilterSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14))
                    Text("Filter & Sort")
                        .font(.custom(AppConstants.Fonts.inter, size: 14))
                        .fontWeight(.medium)
                }
                .foregroundColor(AppConstants.Colors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppConstants.Colors.textSecondary.opacity(0.3), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                        )
                )
            }
            .padding(.trailing, AppConstants.Layout.horizontalPadding)
        }
        .padding(.vertical, 12)
        .background(AppConstants.Colors.background)
    }
    
    private var productsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.fixed(170), spacing: 16),
                GridItem(.fixed(170), spacing: 16)
            ], spacing: 20) {
                ForEach(viewModel.filteredProducts.indices, id: \.self) { index in
                    CategoryProductItemView(
                        product: viewModel.filteredProducts[index],
                        initialDelay: Double.random(in: 0...1)
                    )
                }
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            .padding(.top, 16)
            
            // Bottom padding for safe area
            Rectangle()
                .fill(Color.clear)
                .frame(height: 100)
        }
        .refreshable {
            viewModel.loadProducts(for: category.id)
        }
    }
}

struct FilterTabView: View {
    let title: String
    let isRemovable: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.custom(AppConstants.Fonts.inter, size: 14))
                .fontWeight(.medium)
                .foregroundColor(isRemovable ? .white : AppConstants.Colors.primary)
            
            if isRemovable {
                Button(action: {
                    // Haptic feedback for filter removal
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    onRemove()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isRemovable ? AppConstants.Colors.primary : AppConstants.Colors.primary.opacity(0.1))
        )
    }
}

struct CategoryProductItemView: View {
    let product: Product
    let initialDelay: Double
    
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    @State private var isFavorite = false
    @State private var favoriteScale: CGFloat = 1.0
    
    private let imageCycleInterval: TimeInterval = 3.0
    
    var body: some View {
        Button(action: handleProductTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image Container
                ZStack(alignment: .topTrailing) {
                    imageContainer
                    gradientOverlay
                    favoriteButton
                    
                    if product.images.count > 1 {
                        imageIndicators
                    }
                }
                .frame(height: 180)
                .frame(width: 170)
                .background(cardBackground)
                
                // Product Info
                productInfo
            }
        }
        .buttonStyle(CategoryProductButtonStyle())
        .onAppear {
            startImageCycling()
        }
        .onDisappear {
            stopImageCycling()
        }
    }
    
    private var imageContainer: some View {
        ZStack {
            ForEach(0..<min(product.images.count, 5), id: \.self) { index in
                CachedAsyncImage(
                    url: product.images[index],
                    contentMode: .fill,
                    width: 170,
                    height: 180,
                    cornerRadius: 12
                )
                .opacity(currentImageIndex == index ? 1.0 : 0.0)
                .scaleEffect(currentImageIndex == index ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 1.0), value: currentImageIndex)
            }
            
            if product.images.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 170, height: 180)
                    .cornerRadius(12)
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
    }
    
    private var gradientOverlay: some View {
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
    }
    
    private var favoriteButton: some View {
        Button(action: handleFavoriteTap) {
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
                )
        }
        .padding(12)
    }
    
    private var imageIndicators: some View {
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
                        .frame(
                            width: currentImageIndex == index ? 8 : 6,
                            height: currentImageIndex == index ? 8 : 6
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentImageIndex)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.name)
                .font(.custom(AppConstants.Fonts.inter, size: 15))
                .fontWeight(.medium)
                .foregroundColor(AppConstants.Colors.text)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text("₹ \(String(format: "%.0f", product.price))")
                .font(.custom(AppConstants.Fonts.inter, size: 16))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.primary)
        }
        .padding(.horizontal, 4)
    }
    
    private func startImageCycling() {
        guard product.images.count > 1 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            timer = Timer.scheduledTimer(withTimeInterval: imageCycleInterval, repeats: true) { _ in
                currentImageIndex = (currentImageIndex + 1) % product.images.count
            }
        }
    }
    
    private func stopImageCycling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleProductTap() {
        // Haptic feedback for product tap
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("Product tapped: \(product.name)")
    }
    
    private func handleFavoriteTap() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isFavorite.toggle()
            favoriteScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                favoriteScale = 1.0
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: isFavorite ? .medium : .light)
        impactFeedback.impactOccurred()
    }
}

struct CategoryProductButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
