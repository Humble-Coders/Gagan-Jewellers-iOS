import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var showingSidebar = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                // Main Content
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                    
                    // Content
                    if viewModel.isLoading {
                        LoadingStateView()
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
        #if os(iOS)
        .navigationBarHidden(true)
        #else
        .navigationTitle("")
        .toolbar(.hidden)
        #endif
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
        .background(AppConstants.Colors.background)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    private var regularTopBar: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingSidebar.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.text)
            }
            
            Spacer()
            
            Text("Gagan Jewellers")
                .font(.custom(AppConstants.Fonts.inter, size: 20))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.primary)
            
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
        ScrollView {
            LazyVStack(spacing: 24) {
                // Carousel - Edge to edge
                if !viewModel.carouselItems.isEmpty {
                    CarouselView(items: viewModel.carouselItems)
                }
                
                // Categories
                if !viewModel.categories.isEmpty {
                    CategoryRowView(categories: viewModel.categories)
                }
                
                // Featured Collection
                if !viewModel.featuredProducts.isEmpty {
                    FeaturedCollectionView(products: viewModel.featuredProducts)
                }
                
                // Collections
                if !viewModel.themedCollections.isEmpty {
                    CollectionsRowView(collections: viewModel.themedCollections)
                }
                
                // Bottom padding for tab bar
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
            }
            .padding(.top, 16)
        }
        .refreshable {
            viewModel.refreshData()
        }
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
                        withAnimation(.easeInOut(duration: 0.3)) {
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
            .background(AppConstants.Colors.background)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 0)
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
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
