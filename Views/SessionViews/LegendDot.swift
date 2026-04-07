//
//  LegendDot.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//


import SwiftUI
struct LegendDot: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(LocalizedStringKey(label)).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
        }
    }
}
