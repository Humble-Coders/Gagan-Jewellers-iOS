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
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primary))
                            
                            Text("Loading...")
                                .font(.custom(AppConstants.Fonts.inter, size: 12))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }
                    )
            }
        }
        .onSuccess { image, data, cacheType in
            // Image loaded successfully
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

// Enhanced version with more control
struct CachedAsyncImage: View {
    let url: String
    let contentMode: ContentMode
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    let showLoadingIndicator: Bool
    
    init(
        url: String,
        contentMode: ContentMode = .fill,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 0,
        showLoadingIndicator: Bool = true
    ) {
        self.url = url
        self.contentMode = contentMode
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.showLoadingIndicator = showLoadingIndicator
    }
    
    var body: some View {
        WebImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            placeholderView
        }
        .onSuccess { image, data, cacheType in
            // Track cache performance
            switch cacheType {
            case .none:
                print("🌐 Downloaded from network: \(URL(string: url)?.lastPathComponent ?? "unknown")")
            case .disk:
                print("💾 Loaded from disk cache: \(URL(string: url)?.lastPathComponent ?? "unknown")")
            case .memory:
                print("⚡ Loaded from memory cache: \(URL(string: url)?.lastPathComponent ?? "unknown")")
            @unknown default:
                print("📱 Loaded from cache: \(URL(string: url)?.lastPathComponent ?? "unknown")")
            }
        }
        .onFailure { error in
            print("❌ Failed to load image \(URL(string: url)?.lastPathComponent ?? "unknown"): \(error.localizedDescription)")
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
        .clipped()
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack(spacing: 4) {
                    if showLoadingIndicator {
                        ProgressView()
                            .scaleEffect(0.7)
                            .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primary))
                    }
                    
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.5))
                }
            )
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
    }
}

// Fallback using native AsyncImage if SDWebImage has issues
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
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    VStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                            .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primary))
                        
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.5))
                    }
                )
        }
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
        .clipped()
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
    }
}
