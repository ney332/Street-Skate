//
//  AboutView.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [Color("verde"), Color("verde")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
//                        Image("Image")
//                            .font(.system(size: 6, weight: .black, design: .rounded))
//                            .foregroundColor(.black)
//                            .frame(width: 2, height: 20)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        Text("Street Skate")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Version 1.0.0")
                            .font(.system(size: 15))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    
                    Text("About.Description".localized)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                    Text("about.made_by".localized)
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .navigationTitle("About".localized)
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

#Preview {
    AboutView()
}
