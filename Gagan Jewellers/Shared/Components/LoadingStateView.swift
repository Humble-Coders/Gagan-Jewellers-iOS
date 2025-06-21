import SwiftUI

struct LoadingStateView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primary))
            
            Text(message)
                .font(.custom(AppConstants.Fonts.inter, size: 16))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.background)
    }
}

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(0.8),
                            Color.orange.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Something went wrong")
                .font(.custom(AppConstants.Fonts.inter, size: 18))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.text)
            
            Text(message)
                .font(.custom(AppConstants.Fonts.inter, size: 14))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.custom(AppConstants.Fonts.inter, size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppConstants.Colors.primary,
                                AppConstants.Colors.primary.opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(AppConstants.Layout.cornerRadius)
                    .shadow(color: AppConstants.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonTitle: String?
    let onButtonTap: (() -> Void)?
    
    init(title: String, message: String, buttonTitle: String? = nil, onButtonTap: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.onButtonTap = onButtonTap
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppConstants.Colors.textSecondary,
                            AppConstants.Colors.textSecondary.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(title)
                .font(.custom(AppConstants.Fonts.inter, size: 18))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.text)
            
            Text(message)
                .font(.custom(AppConstants.Fonts.inter, size: 14))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let buttonTitle = buttonTitle, let onButtonTap = onButtonTap {
                Button(action: onButtonTap) {
                    Text(buttonTitle)
                        .font(.custom(AppConstants.Fonts.inter, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppConstants.Colors.primary,
                                    AppConstants.Colors.primary.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(AppConstants.Layout.cornerRadius)
                        .shadow(color: AppConstants.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }
}
