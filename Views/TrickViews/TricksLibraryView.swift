import SwiftUI

struct TricksLibraryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: TrickCategory? = nil
    @State private var searchText: String = ""
    @State private var showTrickLog = false
    @State private var selectedTrick: SkateTrick? = nil
    
    var unlockedTricks: Set<String> { Set(appState.currentUser?.unlockedTricks ?? []) }
    
    var filteredTricks: [SkateTrick] {
        SkateTrick.allTricks.filter { trick in
            let matchesCategory = selectedCategory == nil || trick.category == selectedCategory
            let matchesSearch = searchText.isEmpty || trick.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.white.opacity(0.4))
                        TextField("", text: $searchText)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search tricks...").foregroundColor(Color.white.opacity(0.3))
                            }
                            .foregroundColor(.white)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryChip(title: "All", isSelected: selectedCategory == nil, onTap: { selectedCategory = nil })
                            ForEach(TrickCategory.allCases, id: \.self) { cat in
                                CategoryChip(title: cat.rawValue, isSelected: selectedCategory == cat, onTap: { selectedCategory = cat })
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    
                    // Stats row
                    HStack {
                        Text("\(unlockedTricks.count) of \(SkateTrick.allTricks.count) unlocked")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.4))
                        Spacer()
                        Text("\(filteredTricks.count) shown")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.3))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    // Tricks list
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredTricks) { trick in
                                Button(action: { selectedTrick = trick }) {
                                    TrickRow(
                                        trick: trick,
                                        isUnlocked: unlockedTricks.contains(trick.name),
                                        onUnlock: { unlockTrick(trick) }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Trick Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showTrickLog = true }) {
//                        Image(systemName: "list.clipboard")
//                            /*.foregroundColor(Color(hex: "#87FF00")*/)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("verde"))
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showTrickLog) {
            TrickLogView().environmentObject(appState)
        }
//        .sheet(item: $selectedTrick) { trick in
//            TrickDetailView(
//                trick: trick,
//                isUnlocked: unlockedTricks.contains(trick.name),
//                onUnlock: { unlockTrick(trick) }
//            )
//        }
    }
    
    func unlockTrick(_ trick: SkateTrick) {
        guard var user = appState.currentUser else { return }
        if !user.unlockedTricks.contains(trick.name) {
            user.unlockedTricks.append(trick.name)
            user.xp += trick.xpReward
            appState.saveUser(user)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : Color.white.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("verde") : Color.white.opacity(0.08))
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct TrickRow: View {
    let trick: SkateTrick
    let isUnlocked: Bool
    let onUnlock: () -> Void
    @State private var showingUnlock = false
    
    var difficultyColor: Color {
        switch trick.difficulty {
        case .beginner: return Color(hex: "#4CAF50")
        case .intermediate: return Color(hex: "#2196F3")
        case .advanced: return Color(hex: "#FF9800")
        case .expert: return Color(hex: "#F44336")
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Lock/unlock indicator
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("verde").opacity(0.15) : Color.white.opacity(0.05))
                    .frame(width: 44, height: 44)
                Image(systemName: isUnlocked ? "checkmark" : "lock.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? Color("verde") : Color.white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trick.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : Color.white.opacity(0.5))
                HStack(spacing: 8) {
                    Text(trick.category.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 3, height: 3)
                    Text(trick.difficulty.rawValue.capitalized)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(difficultyColor)
                }
            }
            
            Spacer()
            
            // XP badge
            VStack(spacing: 2) {
                Text("+\(trick.xpReward)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(isUnlocked ? Color("verde") : Color.white.opacity(0.3))
                Text("XP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isUnlocked ? Color("verde").opacity(0.7) : Color.white.opacity(0.2))
            }
            
            if !isUnlocked {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        showingUnlock = true
                        onUnlock()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { showingUnlock = false }
                }) {
                    Text("Unlock")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(LinearGradient(
                                colors: [Color("verde"), Color("verde")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                        )
                }
                .scaleEffect(showingUnlock ? 0.9 : 1.0)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isUnlocked ? 0.05 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isUnlocked ? Color("verde").opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

