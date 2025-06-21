import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab = 0
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab with elegant transitions
            ZStack {
                // Home Tab
                HomeView()
                    .environmentObject(homeViewModel)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .scaleEffect(selectedTab == 0 ? 1 : 0.95)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                // Categories Tab
                CategoriesView(
                    cachedCategories: homeViewModel.categories,
                    cachedCollections: homeViewModel.themedCollections
                )
                .opacity(selectedTab == 1 ? 1 : 0)
                .scaleEffect(selectedTab == 1 ? 1 : 0.95)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                // Wishlist Tab
                WishlistView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .scaleEffect(selectedTab == 2 ? 1 : 0.95)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                // Profile Tab
                ProfileView()
                    .opacity(selectedTab == 3 ? 1 : 0)
                    .scaleEffect(selectedTab == 3 ? 1 : 0.95)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            
            // Custom Tab Bar with entrance animation
            customTabBar
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var customTabBar: some View {
        HStack {
            tabBarItem(
                title: "Home",
                icon: "house",
                selectedIcon: "house.fill",
                index: 0
            )
            
            tabBarItem(
                title: "Categories",
                icon: "square.grid.2x2",
                selectedIcon: "square.grid.2x2.fill",
                index: 1
            )
            
            tabBarItem(
                title: "Wishlist",
                icon: "heart",
                selectedIcon: "heart.fill",
                index: 2
            )
            
            tabBarItem(
                title: "Profile",
                icon: "person",
                selectedIcon: "person.fill",
                index: 3
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(AppConstants.Colors.background)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private func tabBarItem(title: String, icon: String, selectedIcon: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                selectedTab = index
            }
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == index ? selectedIcon : icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == index ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                
                Text(title)
                    .font(.custom(AppConstants.Fonts.inter, size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(selectedTab == index ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Placeholder views for other tabs
struct WishlistView: View {
    var body: some View {
        VStack {
            Text("Wishlist")
                .font(.custom(AppConstants.Fonts.inter, size: 24))
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.background)
    }
}

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile")
                .font(.custom(AppConstants.Fonts.inter, size: 24))
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.background)
    }
}
