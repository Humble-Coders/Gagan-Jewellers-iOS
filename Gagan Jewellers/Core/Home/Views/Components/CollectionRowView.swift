import SwiftUI

struct CollectionsRowView: View {
    let collections: [ThemedCollection]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Collections")
                    .font(.custom(AppConstants.Fonts.inter, size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.text)
                
                Spacer()
                
                Button("View All") {
                    // Handle view all collections
                }
                .font(.custom(AppConstants.Fonts.inter, size: 14))
                .foregroundColor(AppConstants.Colors.primary)
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(collections.prefix(10)) { collection in
                        CollectionItemView(collection: collection)
                    }
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            }
        }
    }
}

struct CollectionItemView: View {
    let collection: ThemedCollection
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CachedAsyncImage(
                url: collection.imageUrl,
                contentMode: .fill,
                width: 200,
                height: 120,
                cornerRadius: AppConstants.Layout.cornerRadius
            )
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(AppConstants.Layout.cornerRadius)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.custom(AppConstants.Fonts.inter, size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("View All")
                    .font(.custom(AppConstants.Fonts.inter, size: 12))
                    .foregroundColor(AppConstants.Colors.primary)
            }
            .padding(12)
        }
    }
}
