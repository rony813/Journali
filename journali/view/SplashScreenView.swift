//
//  SplashScreenView.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.8
    
    var body: some View {
        if isActive {
            JournalEmptyStateView()
        } else {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Spacer()
                    
                    // Illustration from Assets.xcassets (Image1)
                    Image("Image1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                    
                    // Display Title: 42pt Black
                    Text("Journali")
                        .font(.system(size: 42, weight: .black, design: .default))
                        .foregroundColor(AppColors.textPrimary)
                    
                    // Subtitle: 18pt Light
                    Text("Your thoughts, your story")
                        .font(.system(size: 18, weight: .light, design: .default))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                }
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.opacity = 1.0
                }
                // Transition to main screen after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
#Preview {
    SplashScreenView()
}
