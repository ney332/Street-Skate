//
//  TrickLogView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI

struct TrickLogView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var logService = TrickLogService.shared
    @Environment(\.dismiss) var dismiss

    @State private var selectedTrick: String? = nil
    @State private var showLogEntry = false
    @State private var filterStatus: TrickLogStatus? = nil

    var unlockedTricks: [String] { appState.currentUser?.unlockedTricks ?? [] }

    var filteredEntries: [TrickLogEntry] {
        logService.entries.filter { entry in
            (filterStatus == nil || entry.status == filterStatus)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "All", isSelected: filterStatus == nil, color: Color.white.opacity(0.6)) {
                                filterStatus = nil
                            }
                            ForEach(TrickLogStatus.allCases, id: \.self) { status in
                                FilterChip(label: status.rawValue, isSelected: filterStatus == status, color: status.color) {
                                    filterStatus = (filterStatus == status) ? nil : status
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }

                    if filteredEntries.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            Image(systemName: "list.clipboard")
                                .font(.system(size: 44))
                                .foregroundColor(Color.white.opacity(0.15))
                            Text("No log entries yet")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.3))
                            Text("Log a trick from the Trick Library\nor during a session.")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.2))
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        // Group by date
                        ScrollView {
                            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                                let grouped = Dictionary(grouping: filteredEntries) {
                                    Calendar.current.startOfDay(for: $0.date)
                                }
                                let sortedKeys = grouped.keys.sorted(by: >)

                                ForEach(sortedKeys, id: \.self) { day in
                                    Section {
                                        VStack(spacing: 8) {
                                            ForEach(grouped[day] ?? []) { entry in
                                                TrickLogRow(entry: entry)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    } header: {
                                        HStack {
                                            Text(dayHeader(for: day))
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(Color.white.opacity(0.4))
                                                .tracking(1)
                                                .textCase(.uppercase)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 6)
                                        .background(Color.black)
                                    }
                                }
                            }
                            .padding(.bottom, 40)
                        }
                        .scrollIndicators(.hidden)
                    }

                    // Log trick button
                    Button(action: { showLogEntry = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Log a Trick")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Learned Tricks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "#FFD700"))
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showLogEntry) {
            LogTrickSheet(tricks: unlockedTricks + SkateTrick.allTricks.map { $0.name })
                .environmentObject(appState)
        }
    }

    func dayHeader(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

// MARK: - Log Row
struct TrickLogRow: View {
    let entry: TrickLogEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(entry.status.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.status.icon)
                    .font(.system(size: 18))
                    .foregroundColor(entry.status.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.trickName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text(entry.status.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(entry.status.color)
                    if !entry.note.isEmpty {
                        Text("· \(entry.note)")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.35))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Text(entry.date.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Log Trick Sheet
struct LogTrickSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let tricks: [String]

    @State private var selectedTrick = ""
    @State private var selectedStatus: TrickLogStatus = .landed
    @State private var note = ""
    @State private var searchText = ""

    var filteredTricks: [String] {
        let unique = Array(Set(tricks)).sorted()
        if searchText.isEmpty { return unique }
        return unique.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Status picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How did it go?")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        HStack(spacing: 10) {
                            ForEach(TrickLogStatus.allCases, id: \.self) { status in
                                Button(action: { selectedStatus = status }) {
                                    VStack(spacing: 5) {
                                        Image(systemName: status.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedStatus == status ? .black : status.color)
                                        Text(status.rawValue)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(selectedStatus == status ? .black : status.color)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedStatus == status ? status.color : status.color.opacity(0.1))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Search + list
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.white.opacity(0.3))
                        TextField("", text: $searchText)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search tricks...").foregroundColor(Color.white.opacity(0.25))
                            }
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(filteredTricks, id: \.self) { trick in
                                Button(action: { selectedTrick = trick }) {
                                    HStack {
                                        Text(trick)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        if selectedTrick == trick {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(hex: "#FFD700"))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedTrick == trick
                                                  ? Color(hex: "#FFD700").opacity(0.1)
                                                  : Color.white.opacity(0.04))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedTrick == trick
                                                            ? Color(hex: "#FFD700").opacity(0.3)
                                                            : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .scrollIndicators(.hidden)

                    // Save button
                    Button(action: save) {
                        PrimaryButton(title: "Log Trick", isEnabled: !selectedTrick.isEmpty)
                    }
                    .disabled(selectedTrick.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Log a Trick")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    func save() {
        guard !selectedTrick.isEmpty else { return }
        TrickLogService.shared.log(trick: selectedTrick, status: selectedStatus, note: note)

        // If first time and not yet unlocked, unlock it
        if selectedStatus == .firstTime || selectedStatus == .landed {
            if var user = appState.currentUser, !user.unlockedTricks.contains(selectedTrick) {
                if let trick = SkateTrick.allTricks.first(where: { $0.name == selectedTrick }) {
                    user.unlockedTricks.append(selectedTrick)
                    user.xp += trick.xpReward
                    appState.saveUser(user)
                }
            }
        }
        dismiss()
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : color)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isSelected ? color : color.opacity(0.12))
                )
                .overlay(
                    Capsule().stroke(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
