//
//  GPSIndicatorView.swift
//  StreetSkate
//
//  Created by Lorran on 31/03/26.
//

import SwiftUI

struct GPSIndicatorView: View {
    @ObservedObject var viewModel: LocationViewModel
    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.isUsingLocation ? "figure.skateboarding" : "figure.skateboarding")
                .foregroundColor(viewModel.isUsingLocation ? .blue : .gray)
                .imageScale(.large)
                .scaleEffect(viewModel.isUsingLocation ? (pulse ? 1.06 : 0.94) : 1.0)
                .animation(viewModel.isUsingLocation ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true) : .default, value: pulse)
                .onChange(of: viewModel.isUsingLocation) { _, newValue in
                    if newValue {
                        pulse = true
                    } else {
                        pulse = false
                    }
                }
                .onAppear {
                    if viewModel.isUsingLocation {
                        pulse = true
                    }
                }

            Text(viewModel.isUsingLocation ? "Location active" : "Location off")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(10)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
        )
        .overlay(
            Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.25), value: viewModel.isUsingLocation)
    }
}

