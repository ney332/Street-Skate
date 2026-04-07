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
                                Text("Search tricks...".localized).foregroundColor(Color.white.opacity(0.3))
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
                            CategoryChip(title: "All".localized, isSelected: selectedCategory == nil, onTap: { selectedCategory = nil })
                            ForEach(TrickCategory.allCases, id: \.self) { cat in
                                CategoryChip(title: cat.localizedName, isSelected: selectedCategory == cat, onTap: { selectedCategory = cat })
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    
                    // Stats row
                    HStack {
                        Text("tricks.count.unlocked".localized(unlockedTricks.count, SkateTrick.allTricks.count))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.4))
                        Spacer()
                        Text("tricks.count.shown".localized(filteredTricks.count))
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
            .navigationTitle("Trick Library".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
//                            /*.foregroundColor(Color(hex: "#87FF00")*/)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) { dismiss() }
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
            Text(LocalizedStringKey(title))
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
