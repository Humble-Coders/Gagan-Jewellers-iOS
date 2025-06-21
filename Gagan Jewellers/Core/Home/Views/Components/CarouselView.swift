import SwiftUI
import UIKit
import SDWebImageSwiftUI

struct EnhancedCarouselView: View {
    let items: [CarouselItem]
    @Binding var scrollOffset: CGFloat
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State private var isUserInteracting = false
    @State private var restartTimer: Timer?
    
    private let autoScrollInterval: TimeInterval = 4.0
    private let restartDelay: TimeInterval = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    EnhancedCarouselItemView(item: item, geometry: geometry)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 280) // Increased height for hero prominence
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        }
        .frame(height: 280)
        .onAppear {
            setupPageControl()
            startAutoScroll()
        }
        .onDisappear {
            stopAllTimers()
        }
        .onChange(of: currentIndex) { _ in
            handleUserInteraction()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    handleUserInteraction()
                }
        )
    }
    
    private func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(AppConstants.Colors.primary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
    }
    
    private func startAutoScroll() {
        guard items.count > 1 && !isUserInteracting else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentIndex = (currentIndex + 1) % items.count
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleUserInteraction() {
        isUserInteracting = true
        stopAutoScroll()
        
        restartTimer?.invalidate()
        
        restartTimer = Timer.scheduledTimer(withTimeInterval: restartDelay, repeats: false) { _ in
            isUserInteracting = false
            startAutoScroll()
        }
    }
    
    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        restartTimer?.invalidate()
        restartTimer = nil
    }
}

struct EnhancedCarouselItemView: View {
    let item: CarouselItem
    let geometry: GeometryProxy
    @State private var parallaxOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Image with Parallax Effect
            WebImage(url: createValidURL(from: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 280)
                    .offset(y: parallaxOffset * 0.3) // Parallax effect
                    .clipped()
            } placeholder: {
                SkeletonShimmerView()
                    .frame(width: geometry.size.width, height: 280)
            }
            .onSuccess { image, data, cacheType in
                print("✅ Enhanced carousel loaded: \(item.title)")
            }
            .onFailure { error in
                print("❌ Enhanced carousel failed: \(item.title)")
            }
            
            // Enhanced Gradient Overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0.0),
                    .init(color: Color.clear, location: 0.3),
                    .init(color: Color.black.opacity(0.2), location: 0.6),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Enhanced Content Overlay
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        // Category/Title
                        Text(item.title)
                            .font(.custom(AppConstants.Fonts.inter, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                        
                        // Main Subtitle with gradient text
                        Text(item.subtitle)
                            .font(.custom(AppConstants.Fonts.inter, size: 28))
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white,
                                        AppConstants.Colors.primary.opacity(0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                            .lineLimit(2)
                        
                        // Enhanced CTA Button
                        Button(action: {
                            handleCarouselAction(item: item)
                        }) {
                            HStack(spacing: 10) {
                                Text(item.buttonText)
                                    .font(.custom(AppConstants.Fonts.inter, size: 15))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white,
                                        AppConstants.Colors.primary.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppConstants.Colors.primary.opacity(0.3),
                                                Color.clear
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .scaleEffect(1.0)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(height: 280)
        .cornerRadius(16)
        .clipped()
    }
    
    private func handleCarouselAction(item: CarouselItem) {
        print("Enhanced carousel action: \(item.actionType) -> \(item.actionTarget)")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func createValidURL(from urlString: String) -> URL? {
        let cleanedString = urlString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "%0A", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        if cleanedString.contains("firebasestorage.googleapis.com") &&
           cleanedString.contains("?alt=media") {
            return URL(string: cleanedString)
        }
        return nil
    }
}
