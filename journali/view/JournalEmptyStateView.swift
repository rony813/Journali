//
//  JournalEmptyStateView.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//

import SwiftUI

struct JournalEmptyStateView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Bar (Title + Navigation Actions)[cite: 1]
                HStack {
                    Text("Journal")
                        .font(.system(size: 34, weight: .bold)) // Heading / L
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    // Top Right Actions (Filter & Add)[cite: 1]
                    HStack(spacing: 16) {
                        Button(action: {
                            // Filter Action
                        }) {
                            Image(systemName: "line.3.horizontal.decrease") // SF Symbol
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Button(action: {
                            // Add New Journal Action
                        }) {
                            Image(systemName: "plus") // SF Symbol[cite: 4]
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Central Empty State Graphic & Copy[cite: 1]
                VStack(spacing: 16) {
                    // Open Book Illustration (Image2)
                    Image("Image2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                    
                    // Main Heading: 24pt Bold Text/Accent[cite: 2, 3]
                    Text("Begin Your Journal")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.textAccent)
                    
                    // Subtitle / Supporting text: 18pt Light[cite: 3]
                    Text("Craft your personal diary, tap the\nplus icon to begin")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // Bottom Search Bar[cite: 1]
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("Search", text: $searchText)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Image(systemName: "mic.fill")
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(22)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
}
#Preview {
    JournalEmptyStateView()
}
