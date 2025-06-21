import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    CategoriesView()
                case 2:
                    WishlistView()
                case 3:
                    ProfileView()
                default:
                    HomeView()
                }
            }
            
            // Custom Tab Bar
            customTabBar
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
                icon: "grid.circle",
                selectedIcon: "grid.circle.fill",
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
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(AppConstants.Colors.background)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private func tabBarItem(title: String, icon: String, selectedIcon: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
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
struct CategoriesView: View {
    var body: some View {
        VStack {
            Text("Categories")
                .font(.custom(AppConstants.Fonts.inter, size: 24))
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.background)
    }
}

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
