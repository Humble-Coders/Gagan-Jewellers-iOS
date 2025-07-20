import SwiftUI

struct CategoryRowView: View {
    let categories: [Category]
    
    @State private var scrollOffset: CGFloat = 0
    @State private var timer: Timer?
    @State private var isUserInteracting = false
    @State private var restartTimer: Timer?
    
    private let scrollSpeed: CGFloat = 0.5 // Increased from 0.3
    private let restartDelay: TimeInterval = 3.0
    private let itemWidth: CGFloat = 96 // Approximate item width including spacing
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    // Triple the categories for seamless infinite scroll
                    ForEach(tripleCategories.indices, id: \.self) { index in
                        let category = tripleCategories[index]
                        CategoryItemView(category: category)
                            .id(index)
                    }
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                .offset(x: scrollOffset)
            }
            .onAppear {
                startInfiniteScroll()
            }
            .onDisappear {
                stopAllTimers()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handleUserInteraction()
                        
                        // Allow user to scroll but prevent opposite direction interference
                        let translation = value.translation.width
                        
                        // Only allow manual scrolling if it's in a reasonable range
                        if abs(translation) > 5 {
                            stopInfiniteScroll()
                        }
                    }
                    .onEnded { _ in
                        // Resume auto scroll after user finishes dragging
                        scheduleAutoScrollResume()
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        handleUserInteraction()
                    }
            )
        }
    }
    
    // Create tripled array for seamless infinite scroll
    private var tripleCategories: [Category] {
        guard !categories.isEmpty else { return [] }
        return categories + categories + categories
    }
    
    private func startInfiniteScroll() {
        guard !categories.isEmpty && !isUserInteracting else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let newOffset = scrollOffset - scrollSpeed
            let resetPoint = CGFloat(categories.count) * itemWidth
            
            withAnimation(.linear(duration: 0.05)) {
                if abs(newOffset) >= resetPoint {
                    // Reset to beginning seamlessly
                    scrollOffset = 0
                } else {
                    scrollOffset = newOffset
                }
            }
        }
    }
    
    private func stopInfiniteScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleUserInteraction() {
        isUserInteracting = true
        stopInfiniteScroll()
        
        // Cancel any existing restart timer
        restartTimer?.invalidate()
    }
    
    private func scheduleAutoScrollResume() {
        // Start timer to resume infinite scroll after delay
        restartTimer = Timer.scheduledTimer(withTimeInterval: restartDelay, repeats: false) { _ in
            isUserInteracting = false
            startInfiniteScroll()
        }
    }
    
    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        restartTimer?.invalidate()
        restartTimer = nil
    }
}

struct CategoryItemView: View {
    let category: Category
    @State private var showingCategoryProducts = false
    
    var body: some View {
        Button(action: {
            handleCategoryTap()
        }) {
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
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingCategoryProducts) {
            CategoryProductsView(category: category)
        }
    }
    
    private func handleCategoryTap() {
        print("Category tapped: \(category.name)")
        showingCategoryProducts = true
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}
