import SwiftUI
import UIKit

struct CarouselView: View {
    let items: [CarouselItem]
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State private var isUserInteracting = false
    @State private var restartTimer: Timer?
    
    private let autoScrollInterval: TimeInterval = 4.0
    private let restartDelay: TimeInterval = 5.0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                CarouselItemView(item: item)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 250)
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
        // Stop auto scroll when user interacts
        isUserInteracting = true
        stopAutoScroll()
        
        // Cancel any existing restart timer
        restartTimer?.invalidate()
        
        // Start timer to resume auto scroll after delay
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

struct CarouselItemView: View {
    let item: CarouselItem
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image - Edge to edge
                CachedAsyncImage(
                    url: item.imageUrl,
                    contentMode: .fill,
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .clipped()
                
                // Gradient Overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content Overlay - Fixed positioning
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            // Title
                            Text(item.title)
                                .font(.custom(AppConstants.Fonts.inter, size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Subtitle
                            Text(item.subtitle)
                                .font(.custom(AppConstants.Fonts.inter, size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                            
                            // Button
                            Button(action: {
                                handleCarouselAction(item: item)
                            }) {
                                HStack(spacing: 8) {
                                    Text(item.buttonText)
                                        .font(.custom(AppConstants.Fonts.inter, size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                            }
                            .padding(.top, 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(height: 250)
        .clipped()
    }
    
    private func handleCarouselAction(item: CarouselItem) {
        // Handle carousel button tap
        print("Carousel action: \(item.actionType) -> \(item.actionTarget)")
        // TODO: Implement navigation based on actionType and actionTarget
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// Preview for SwiftUI Canvas
struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItems = [
            CarouselItem(
                id: "1",
                imageUrl: "https://example.com/image1.jpg",
                title: "New Collection",
                subtitle: "Timeless Elegance",
                buttonText: "Discover",
                actionTarget: "collection_1",
                actionType: "collection"
            ),
            CarouselItem(
                id: "2",
                imageUrl: "https://example.com/image2.jpg",
                title: "Featured",
                subtitle: "Gold Jewelry",
                buttonText: "Shop Now",
                actionTarget: "category_gold",
                actionType: "category"
            )
        ]
        
        CarouselView(items: sampleItems)
            .previewLayout(.sizeThatFits)
    }
}
