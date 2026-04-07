//
//  NavigationRowSettings.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//


import SwiftUI

struct NavigationRowSettings: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
