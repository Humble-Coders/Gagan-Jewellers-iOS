//
//  SkeletonLoadingView.swift
//  Gagan Jewellers
//
//  Created by Ansh Bajaj on 21/06/25.
//


import SwiftUI

struct SkeletonLoadingView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Carousel Skeleton
                SkeletonShimmerView()
                    .frame(height: 280)
                    .cornerRadius(16)
                    .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                    .padding(.bottom, 32)
                
                // Section divider skeleton
                skeletonDivider
                
                // Categories Section Skeleton
                VStack(spacing: 24) {
                    // Section header skeleton
                    VStack(spacing: 8) {
                        SkeletonShimmerView()
                            .frame(width: 180, height: 24)
                        SkeletonShimmerView()
                            .frame(width: 140, height: 16)
                    }
                    .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                    
                    // Categories row skeleton
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<6, id: \.self) { _ in
                                VStack(spacing: 8) {
                                    SkeletonShimmerView()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                    
                                    SkeletonShimmerView()
                                        .frame(width: 50, height: 12)
                                }
                            }
                        }
                        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                    }
                }
                .padding(.vertical, 32)
                
                skeletonDivider
                
                // Featured Products Section Skeleton
                VStack(spacing: 24) {
                    // Section header skeleton
                    VStack(spacing: 8) {
                        SkeletonShimmerView()
                            .frame(width: 160, height: 24)
                        SkeletonShimmerView()
                            .frame(width: 120, height: 16)
                    }
                    .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                    
                    // Products grid skeleton
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 20) {
                        ForEach(0..<4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 12) {
                                SkeletonShimmerView()
                                    .frame(height: 160)
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    SkeletonShimmerView()
                                        .frame(height: 16)
                                    SkeletonShimmerView()
                                        .frame(width: 80, height: 14)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                }
                .padding(.vertical, 32)
                
                // Bottom padding
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 120)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppConstants.Colors.background,
                    AppConstants.Colors.background.opacity(0.98)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var skeletonDivider: some View {
        VStack(spacing: 8) {
            SkeletonShimmerView()
                .frame(width: 200, height: 1)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 4, height: 4)
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
    }
}

struct SkeletonShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.gray.opacity(0.2), location: 0.0),
                        .init(color: Color.gray.opacity(0.1), location: 0.3),
                        .init(color: Color.gray.opacity(0.05), location: 0.5),
                        .init(color: Color.gray.opacity(0.1), location: 0.7),
                        .init(color: Color.gray.opacity(0.2), location: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                AppConstants.Colors.primary.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: isAnimating ? 200 : -200)
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            )
            .clipped()
            .onAppear {
                isAnimating = true
            }
    }
}