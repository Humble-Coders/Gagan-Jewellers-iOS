import SwiftUI

struct FilterSortSheet: View {
    @ObservedObject var viewModel: CategoryProductsViewModel
    @Binding var isPresented: Bool
    @State private var selectedTab: FilterTab = .material
    
    enum FilterTab: String, CaseIterable {
        case material = "Material"
        case gender = "Gender"
        case sort = "Sort"
        
        var icon: String {
            switch self {
            case .material: return "diamond"
            case .gender: return "person.2"
            case .sort: return "arrow.up.arrow.down"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab Selection
                tabSelectionView
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .material:
                            materialFilterView
                        case .gender:
                            genderFilterView
                        case .sort:
                            sortOptionsView
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                }
                
                // Bottom Actions
                bottomActionsView
            }
            .background(Color(.systemGroupedBackground))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var headerView: some View {
        HStack {
            Button("Reset") {
                viewModel.resetFilters()
            }
            .font(.custom(AppConstants.Fonts.inter, size: 16))
            .foregroundColor(AppConstants.Colors.primary)
            
            Spacer()
            
            Text("Filter & Sort")
                .font(.custom(AppConstants.Fonts.inter, size: 18))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.text)
            
            Spacer()
            
            Button("Done") {
                viewModel.applyFilters()
                isPresented = false
            }
            .font(.custom(AppConstants.Fonts.inter, size: 16))
            .fontWeight(.medium)
            .foregroundColor(AppConstants.Colors.primary)
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    private var tabSelectionView: some View {
        HStack {
            ForEach(FilterTab.allCases, id: \.self) { tab in
                Button(action: {
                    // Haptic feedback for tab selection
                    let selectionFeedback = UISelectionFeedbackGenerator()
                    selectionFeedback.selectionChanged()
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                            .foregroundColor(selectedTab == tab ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                        
                        Text(tab.rawValue)
                            .font(.custom(AppConstants.Fonts.inter, size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == tab ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedTab == tab ? AppConstants.Colors.primary.opacity(0.1) : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private var materialFilterView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if viewModel.materials.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    Text("No materials found")
                        .font(.custom(AppConstants.Fonts.inter, size: 16))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    Text("Please check your internet connection and try again")
                        .font(.custom(AppConstants.Fonts.inter, size: 12))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.materials, id: \.id) { material in
                    MaterialFilterSection(
                        material: material,
                        selectedMaterials: $viewModel.selectedMaterials,
                        selectedMaterialTypes: $viewModel.selectedMaterialTypes
                    )
                }
            }
        }
        .onAppear {
            print("🔍 MaterialFilterView appeared with \(viewModel.materials.count) materials")
        }
    }
    
    private var genderFilterView: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Gender")
            
            let genderOptions = ["All", "Men", "Women", "Unisex"]
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(genderOptions, id: \.self) { gender in
                    Button(action: {
                        // Haptic feedback for gender selection
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        viewModel.selectedGender = gender == "All" ? nil : gender
                    }) {
                        HStack {
                            Image(systemName: (viewModel.selectedGender == gender || (viewModel.selectedGender == nil && gender == "All")) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor((viewModel.selectedGender == gender || (viewModel.selectedGender == nil && gender == "All")) ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                                .font(.system(size: 16))
                            
                            Text(gender)
                                .font(.custom(AppConstants.Fonts.inter, size: 14))
                                .foregroundColor(AppConstants.Colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                        )
                    }
                }
            }
        }
    }
    
    private var sortOptionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Sort By")
            
            ForEach(CategoryProductsViewModel.SortOption.allCases, id: \.self) { sortOption in
                Button(action: {
                    // Haptic feedback for sort selection
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    viewModel.sortBy = sortOption
                }) {
                    HStack {
                        Image(systemName: viewModel.sortBy == sortOption ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.sortBy == sortOption ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                            .font(.system(size: 16))
                        
                        Text(sortOption.displayName)
                            .font(.custom(AppConstants.Fonts.inter, size: 14))
                            .foregroundColor(AppConstants.Colors.text)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                }
            }
        }
    }
    
    private var bottomActionsView: some View {
        VStack(spacing: 16) {
            // Results Counter
            HStack {
                Text("Results: \(viewModel.filteredProducts.count)")
                    .font(.custom(AppConstants.Fonts.inter, size: 14))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                Spacer()
                
                if viewModel.activeFilters.count > 1 || viewModel.activeFilters.first != "All" {
                    Text("\(viewModel.activeFilters.count) filter\(viewModel.activeFilters.count == 1 ? "" : "s") applied")
                        .font(.custom(AppConstants.Fonts.inter, size: 12))
                        .foregroundColor(AppConstants.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppConstants.Colors.primary.opacity(0.1))
                        )
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Clear All Button (only show if filters are applied)
                if viewModel.activeFilters.count > 1 || viewModel.activeFilters.first != "All" {
                    Button(action: {
                        // Haptic feedback for clear all
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.resetFilters()
                        }
                    }) {
                        Text("Clear All")
                            .font(.custom(AppConstants.Fonts.inter, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(AppConstants.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppConstants.Colors.primary, lineWidth: 1.5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                    )
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Apply Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.applyFilters()
                    }
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Delay dismiss slightly for better UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPresented = false
                    }
                }) {
                    Text("Apply Filters")
                        .font(.custom(AppConstants.Fonts.inter, size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppConstants.Colors.primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, AppConstants.Layout.horizontalPadding)
        .padding(.vertical, 20)
        .padding(.bottom, 10) // Extra bottom padding for safe area
        .background(Color.white)
    }
}

struct MaterialFilterSection: View {
    let material: Material
    @Binding var selectedMaterials: Set<String>
    @Binding var selectedMaterialTypes: Set<String>
    @State private var isExpanded = false
    
    private var isSelected: Bool {
        selectedMaterials.contains(material.id)
    }
    
    private var hasSelectedTypes: Bool {
        material.types.contains { selectedMaterialTypes.contains($0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Material Header with separated click areas
            HStack {
                // Left portion - Selection area
                Button(action: {
                    // Haptic feedback for material selection
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if isSelected {
                            // Deselect material and all its types
                            selectedMaterials.remove(material.id)
                            for type in material.types {
                                selectedMaterialTypes.remove(type)
                            }
                        } else {
                            // Select material
                            selectedMaterials.insert(material.id)
                        }
                    }
                }) {
                    HStack {
                        // Selection indicator
                        Image(systemName: isSelected || hasSelectedTypes ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected || hasSelectedTypes ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                            .font(.system(size: 18))
                            .animation(.easeInOut(duration: 0.2), value: isSelected || hasSelectedTypes)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(material.name)
                                .font(.custom(AppConstants.Fonts.inter, size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(AppConstants.Colors.text)
                            
                            if !material.types.isEmpty {
                                Text("\(material.types.count) type\(material.types.count == 1 ? "" : "s")")
                                    .font(.custom(AppConstants.Fonts.inter, size: 12))
                                    .foregroundColor(AppConstants.Colors.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Right portion - Expand/Collapse area (only if has types)
                if !material.types.isEmpty {
                    Button(action: {
                        // Haptic feedback for expand/collapse
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            .frame(width: 40, height: 40)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected || hasSelectedTypes ? AppConstants.Colors.primary.opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected || hasSelectedTypes ? AppConstants.Colors.primary.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected || hasSelectedTypes ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected || hasSelectedTypes)
            
            // Material Types (expanded)
            if isExpanded && !material.types.isEmpty {
                VStack(spacing: 8) {
                    ForEach(material.types, id: \.self) { type in
                        Button(action: {
                            // Haptic feedback for type selection
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedMaterialTypes.contains(type) {
                                    selectedMaterialTypes.remove(type)
                                    // If no types selected, also deselect the material
                                    if !material.types.contains(where: { selectedMaterialTypes.contains($0) }) {
                                        selectedMaterials.remove(material.id)
                                    }
                                } else {
                                    selectedMaterialTypes.insert(type)
                                    // Also select the parent material
                                    selectedMaterials.insert(material.id)
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedMaterialTypes.contains(type) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedMaterialTypes.contains(type) ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                                    .font(.system(size: 16))
                                    .animation(.easeInOut(duration: 0.2), value: selectedMaterialTypes.contains(type))
                                
                                Text(type)
                                    .font(.custom(AppConstants.Fonts.inter, size: 14))
                                    .foregroundColor(AppConstants.Colors.text)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedMaterialTypes.contains(type) ? AppConstants.Colors.primary.opacity(0.1) : Color.gray.opacity(0.05))
                            )
                            .scaleEffect(selectedMaterialTypes.contains(type) ? 1.02 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: selectedMaterialTypes.contains(type))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
            }
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom(AppConstants.Fonts.inter, size: 18))
            .fontWeight(.semibold)
            .foregroundColor(AppConstants.Colors.text)
            .padding(.bottom, 8)
    }
}

