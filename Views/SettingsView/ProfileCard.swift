//
//  ProfileCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct ProfileCard: View {
    let user: UserProfile?
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                LinearGradient(
                    colors: [Color("verde"), Color("verde")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                
                Text(String(user?.name.prefix(1) ?? "S").uppercased())
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user?.name ?? "user.default_name".localized)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(user?.level.localizedName ?? "level.amateur.name".localized)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("verde"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#FFD700").opacity(0.12))
                        .cornerRadius(8)
                    
                    Text("profile.age".localized(user?.age ?? 0))
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                Text("profile.total_xp".localized(user?.xp ?? 0))
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("verde").opacity(0.15), lineWidth: 1)
                )
        )
    }
}
