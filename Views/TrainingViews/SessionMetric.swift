//
//  SessionMetric.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI

struct SessionMetric: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "#87FF00"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
    }
}
