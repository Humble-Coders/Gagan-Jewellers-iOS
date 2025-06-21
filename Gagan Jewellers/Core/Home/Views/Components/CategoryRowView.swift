import SwiftUI

struct CategoryRowView: View {
    let categories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(categories) { category in
                    CategoryItemView(category: category)
                }
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        }
    }
}

struct CategoryItemView: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 8) {
            CachedAsyncImage(
                url: category.imageUrl,
                contentMode: .fill,
                width: 60,
                height: 60,
                cornerRadius: 30
            )
            .overlay(
                Circle()
                    .stroke(AppConstants.Colors.primary.opacity(0.3), lineWidth: 2)
            )
            
            Text(category.name)
                .font(.custom(AppConstants.Fonts.inter, size: 12))
                .fontWeight(.medium)
                .foregroundColor(AppConstants.Colors.text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80)
    }
}
