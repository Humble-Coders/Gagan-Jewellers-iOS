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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(
                    url: product.images.first ?? "",
                    contentMode: .fill,
                    height: 150,
                    cornerRadius: AppConstants.Layout.cornerRadius
                )
                
                Button(action: {
                    // Handle favorite toggle
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(8)
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
}
