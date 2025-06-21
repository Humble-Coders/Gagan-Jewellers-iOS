import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var isSearching = false
    @State private var searchText = ""
    
    // Accept cached data from parent (CustomTabView)
    var cachedCategories: [Category]?
    var cachedCollections: [ThemedCollection]?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                // Content
                if viewModel.isLoading {
                    LoadingStateView(message: "Loading categories...")
                } else if let error = viewModel.error {
                    ErrorStateView(message: error) {
                        viewModel.loadData()
                    }
                } else {
                    contentView
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadData(
                cachedCategories: cachedCategories,
                cachedCollections: cachedCollections
            )
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
            // Empty space for symmetry (same width as the right side buttons)
            Spacer()
                .frame(width: 88, height: 44)
            
            Spacer()
            
            Text("Categories")
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
            .frame(width: 88, height: 44) // Fixed frame for consistent spacing
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search categories...", text: $searchText)
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
            LazyVStack(spacing: 32) {
                // Categories Grid
                if !filteredCategories.isEmpty {
                    CategoryGridView(categories: filteredCategories)
                        .padding(.top, 24)
                }
                
                // Featured Collections
                if !isSearching && !viewModel.themedCollections.isEmpty {
                    FeaturedCollectionsGridView(collections: viewModel.themedCollections)
                }
                
                // Bottom padding for tab bar
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
            }
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter { category in
                category.name.localizedCaseInsensitiveContains(searchText) ||
                category.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// Preview
struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
