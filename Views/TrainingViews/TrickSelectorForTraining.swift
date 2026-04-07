//
//  TrickSelectorForTraining.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct TrickSelectorForTraining: View {
    let user: UserProfile?
    @Binding var selectedTricks: Set<String>
    let onStart: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("What will you practice?".localized)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(SkateTrick.allTricks) { trick in
                                let isUnlocked = user?.unlockedTricks.contains(trick.name) ?? false
                                let isSelected = selectedTricks.contains(trick.name)
                                
                                Button(action: {
                                    if isSelected {
                                        selectedTricks.remove(trick.name)
                                    } else {
                                        selectedTricks.insert(trick.name)
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(trick.name)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(trick.category.localizedName)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.white.opacity(0.4))
                                        }
                                        Spacer()
                                        if isUnlocked {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(Color("verde"))
                                                .font(.system(size: 14))
                                        }
                                        ZStack {
                                            Circle()
                                                .stroke(isSelected ? Color("verde") : Color.white.opacity(0.2), lineWidth: 2)
                                                .frame(width: 24, height: 24)
                                            if isSelected {
                                                Circle()
                                                    .fill(Color("verde"))
                                                    .frame(width: 14, height: 14)
                                            }
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(isSelected ? Color("verde").opacity(0.08) : Color.white.opacity(0.04))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(isSelected ? Color("verde").opacity(0.3) : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    
                    VStack(spacing: 0) {
                        Divider().background(Color.white.opacity(0.1))
                        Button(action: onStart) {
                            PrimaryButton(
                                title: selectedTricks.isEmpty
                                    ? "Start Free Session".localized
                                    : "Start with %d tricks".localized(selectedTricks.count),
                                isEnabled: true
                            )
                        }
                        .padding(20)
                    }
                    .background(Color.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) { dismiss() }
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
