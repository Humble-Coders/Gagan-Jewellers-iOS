import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var showingSidebar = false
    @State private var carouselScrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                // Main Content
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                    
                    // Content
                    if viewModel.isLoading {
                        SkeletonLoadingView()
                    } else if let error = viewModel.error {
                        ErrorStateView(message: error) {
                            viewModel.loadData()
                        }
                    } else {
                        contentView
                    }
                }
                
                // Sidebar
                if showingSidebar {
                    sidebarView
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.carouselItems.isEmpty {
                viewModel.loadData()
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            if isSearching {
                searchBar
            } else {
                regularTopBar
            }
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppConstants.Colors.background,
                    AppConstants.Colors.background.opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var regularTopBar: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showingSidebar.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.text)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            Text("Gagan Jewellers")
                .font(.custom(AppConstants.Fonts.inter, size: 20))
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
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSearching = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(AppConstants.Colors.text)
                }
                
                Button(action: {
                    // Handle favorites
                }) {
                    Image(systemName: "heart")
                        .font(.system(size: 18))
                        .foregroundColor(AppConstants.Colors.text)
                }
            }
            .frame(width: 88, height: 44)
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search jewelry...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.custom(AppConstants.Fonts.inter, size: 16))
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = false
                    searchText = ""
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundColor(AppConstants.Colors.text)
            }
        }
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) { // Changed from LazyVStack to regular VStack
                    // Hero Carousel Section
                    if !viewModel.carouselItems.isEmpty {
                        VStack(spacing: 0) {
                            EnhancedCarouselView(
                                items: viewModel.carouselItems,
                                scrollOffset: $carouselScrollOffset
                            )
                            
                            // Elegant section divider
                            sectionDivider
                        }
                    }
                    
                    // Categories Section
                    if !viewModel.categories.isEmpty {
                        VStack(spacing: 24) {
                            sectionHeader(title: "Explore by Category", subtitle: "Discover our finest collections")
                            
                            CategoryRowView(categories: viewModel.categories)
                        }
                        .padding(.vertical, 24)
                        
                        sectionDivider
                    }
                    
                    // Featured Collection Section
                    if !viewModel.featuredProducts.isEmpty {
                        VStack(spacing: 24) {
                            sectionHeader(title: "Featured Collection", subtitle: "Handpicked for you")
                            
                            // Allow internal animations but disable layout animations
                            EnhancedFeaturedCollectionView(products: viewModel.featuredProducts)
                                .animation(.none, value: viewModel.featuredProducts.count) // Only disable layout changes
                        }
                        .animation(.none, value: viewModel.featuredProducts.count) // Disable VStack layout animations
                        .padding(.vertical, 24)
                        
                        sectionDivider
                    }
                    
                    // Collections Section
                    if !viewModel.themedCollections.isEmpty {
                        VStack(spacing: 24) {
                            sectionHeader(title: "Our Collections", subtitle: "Curated themes and styles")
                            
                            CollectionsRowView(collections: viewModel.themedCollections)
                        }
                        .padding(.vertical, 24)
                    }
                    
                    // Bottom padding for tab bar
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppConstants.Colors.background,
                        AppConstants.Colors.background.opacity(0.98)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .refreshable {
            viewModel.refreshData()
        }
    }
    
    private var sectionDivider: some View {
        VStack(spacing: 8) {
            // Main divider line with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            AppConstants.Colors.primary.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .frame(maxWidth: 200)
            
            // Decorative center dot
            Circle()
                .fill(AppConstants.Colors.primary.opacity(0.4))
                .frame(width: 4, height: 4)
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
    }
    
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.custom(AppConstants.Fonts.inter, size: 22))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.text)
            
            Text(subtitle)
                .font(.custom(AppConstants.Fonts.inter, size: 14))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
    }
    
    private var sidebarView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Menu")
                        .font(.custom(AppConstants.Fonts.inter, size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.text)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showingSidebar = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(AppConstants.Colors.text)
                    }
                }
                .padding(.top, 60)
                
                // Menu items
                VStack(alignment: .leading, spacing: 16) {
                    menuItem("Home", icon: "house")
                    menuItem("Categories", icon: "grid.circle")
                    menuItem("Collections", icon: "square.grid.2x2")
                    menuItem("Favorites", icon: "heart")
                    menuItem("Profile", icon: "person")
                    menuItem("Settings", icon: "gear")
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: 280)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppConstants.Colors.background,
                        AppConstants.Colors.background.opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 5, y: 0)
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showingSidebar = false
            }
        }
    }
    
    private func menuItem(_ title: String, icon: String) -> some View {
        Button(action: {
            // Handle menu item selection
            showingSidebar = false
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.primary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.custom(AppConstants.Fonts.inter, size: 16))
                    .foregroundColor(AppConstants.Colors.text)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}
