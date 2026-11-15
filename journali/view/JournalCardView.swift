//
//  JournalCardView.swift
//  journali
//
//  Created by RON on 05/06/1448 AH.
//

import SwiftUI

struct JournalCardView: View {
    let entry: JournalEntry
    let onBookmarkTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 24, weight: .semibold)) // Title / Card
                        .foregroundColor(AppColors.textAccent)
                    
                    Text(entry.formattedDate)
                        .font(.system(size: 14, weight: .regular)) // Caption / S
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: onBookmarkTap) {
                    Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textAccent)
                }
            }
            
            Text(entry.content)
                .font(.system(size: 18, weight: .regular)) // Body / M
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(4)
                .padding(.top, 4)
        }
        .padding(16)
        .background(AppColors.surfaceCard)
        .cornerRadius(16)
    }
}
