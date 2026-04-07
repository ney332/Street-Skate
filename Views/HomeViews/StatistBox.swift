//
//  StatBox.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//




import SwiftUI


struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("verde"))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(LocalizedStringKey(label))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

