import SwiftUI
import SDWebImageSwiftUI

struct AsyncImageView: View {
    let url: String
    let contentMode: ContentMode
    let placeholder: AnyView?
    
    init(url: String, contentMode: ContentMode = .fill, placeholder: AnyView? = nil) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    var body: some View {
        WebImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            if let placeholder = placeholder {
                placeholder
            } else {
                SkeletonShimmerView()
            }
        }
        .onSuccess { image, data, cacheType in
            if cacheType == .none {
                print("Image downloaded: \(url)")
            } else {
                print("Image loaded from cache: \(url)")
            }
        }
        .onFailure { error in
            print("Failed to load image: \(error.localizedDescription)")
        }
        .transition(.opacity.combined(with: .scale))
    }
}

// Enhanced version with more control and better gradients
struct CachedAsyncImage: View {
    let url: String
    let contentMode: ContentMode
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    let showLoadingIndicator: Bool
    let hasGradientOverlay: Bool
    
    @State private var isLoading = true
    @State private var hasError = false
    
    init(
        url: String,
        contentMode: ContentMode = .fill,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 0,
        showLoadingIndicator: Bool = true,
        hasGradientOverlay: Bool = false
    ) {
        self.url = url
        self.contentMode = contentMode
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.showLoadingIndicator = showLoadingIndicator
        self.hasGradientOverlay = hasGradientOverlay
    }
    
    var body: some View {
        ZStack {
            WebImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .onAppear {
                        isLoading = false
                        hasError = false
                    }
            } placeholder: {
                placeholderView
            }
            .onSuccess { image, data, cacheType in
                isLoading = false
                hasError = false
                
                switch cacheType {
                case .none:
                    print("🌐 Downloaded: \(URL(string: url)?.lastPathComponent ?? "unknown")")
                case .disk:
                    print("💾 Disk cache: \(URL(string: url)?.lastPathComponent ?? "unknown")")
                case .memory:
                    print("⚡ Memory cache: \(URL(string: url)?.lastPathComponent ?? "unknown")")
                @unknown default:
                    print("📱 Cache: \(URL(string: url)?.lastPathComponent ?? "unknown")")
                }
            }
            .onFailure { error in
                isLoading = false
                hasError = true
                print("❌ Failed: \(URL(string: url)?.lastPathComponent ?? "unknown")")
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            
            // Enhanced gradient overlay for better text readability
            if hasGradientOverlay && !isLoading && !hasError {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.clear, location: 0.0),
                        .init(color: Color.clear, location: 0.4),
                        .init(color: Color.black.opacity(0.1), location: 0.7),
                        .init(color: Color.black.opacity(0.4), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
        .clipped()
    }
    
    private var placeholderView: some View {
        Group {
            if hasError {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .red.opacity(0.7),
                                    .orange.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Failed to load")
                        .font(.custom(AppConstants.Fonts.inter, size: 10))
                        .foregroundColor(.red.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        isLoading = true
                        hasError = false
                    }
                    .font(.custom(AppConstants.Fonts.inter, size: 10))
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
                }
                .frame(width: width, height: height)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(cornerRadius)
            } else if showLoadingIndicator && isLoading {
                SkeletonShimmerView()
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppConstants.Colors.textSecondary.opacity(0.5),
                                    AppConstants.Colors.textSecondary.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Image")
                        .font(.custom(AppConstants.Fonts.inter, size: 10))
                        .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.5))
                }
                .frame(width: width, height: height)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(cornerRadius)
            }
        }
    }
}

// Fallback using native AsyncImage with enhanced styling
struct FallbackAsyncImage: View {
    let url: String
    let contentMode: ContentMode
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    
    init(
        url: String,
        contentMode: ContentMode = .fill,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 0
    ) {
        self.url = url
        self.contentMode = contentMode
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            SkeletonShimmerView()
        }
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
        .clipped()
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
    }
}
