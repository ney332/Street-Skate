//
//  OnboardingStep1.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct OnboardingStep1: View {
    @Binding var name: String
    @Binding var age: String
   
    var onNext: () -> Void
    
    @FocusState private var focusedField: Field?
    enum Field { case name, age }
    
    var isValid: Bool { !name.isEmpty && !age.isEmpty }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who are you?")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Tell us about yourself to get started")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                
                VStack(spacing: 16) {
                    FloatingTextField(placeholder: "Your name", text: $name, icon: "person.fill")
                        .focused($focusedField, equals: .name)
                    
                    FloatingTextField(placeholder: "Your age", text: $age, icon: "calendar", keyboardType: .numberPad)
                        .focused($focusedField, equals: .age)
                    
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                focusedField = nil
                onNext()
            }) {
                PrimaryButton(title: "Next", isEnabled: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}
