//
//  SmallDetailMetric.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI

struct SmallDetailMetric: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(LocalizedStringKey(label))
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
