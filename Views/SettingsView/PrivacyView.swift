//
//  PrivacyView.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach([
                            ("privacy.data_collection.title", "privacy.data_collection.body"),
                            ("privacy.health_data.title", "privacy.health_data.body"),
                            ("privacy.local_storage.title", "privacy.local_storage.body"),
                            ("privacy.third_parties.title", "privacy.third_parties.body")
                        ], id: \.0) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.0.localized)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                Text(item.1.localized)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Privacy Policy".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) { dismiss() }.foregroundColor(Color("verde"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
