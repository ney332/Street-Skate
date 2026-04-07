//
//  HomeHeader.swift
//  SkateAppp
//
//  Created by Lorran on 24/03/26.
//
import SwiftUI

struct HomeHeader: View {
    let user: UserProfile?
    var onAchievementsTap: (() -> Void)? = nil
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "greeting.morning".localized }
        else if hour < 17 { return "greeting.afternoon".localized }
        else { return "greeting.evening".localized }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting + ",")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                Text(user?.name ?? "user.default_name".localized)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Achievements button
            Button(action: { onAchievementsTap?() }) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color("verde"))
                    .frame(width: 40, height: 40)
                    .background(Color("verde").opacity(0.12))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("verde").opacity(0.2), lineWidth: 1))
            }
            
            // XP Badge
            VStack(spacing: 2) {
                Text("\(user?.xp ?? 0)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color("verde"))
                Text("XP")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color("verde").opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("verde").opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("verde").opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
    }
}
