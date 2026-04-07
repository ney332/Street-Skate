//
//  InfoPill.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI  

struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(Color("verde"))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}
