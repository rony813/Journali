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
                    // عنوان الجورنال.
                    Text(entry.title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.textAccent)

                    // تاريخ الجورنال.
                    Text(entry.formattedDate)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // إضافة البوك مارك أو إزالته.
                Button(action: onBookmarkTap) {
                    Image(
                        systemName: entry.isBookmarked
                            ? "bookmark.fill"
                            : "bookmark"
                    )
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textAccent)

                    // مساحة لمس أكبر بدون تكبير الأيقونة.
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }

                // استجابة مستقلة للزر داخل List.
                .buttonStyle(.plain)

                // الحفاظ على موضع الأيقونة داخل الكرت.
                .padding(.vertical, -12)
                .padding(.horizontal, -12)

                // وصف الزر لقارئ الشاشة.
                .accessibilityLabel(
                    entry.isBookmarked
                        ? "Remove bookmark"
                        : "Add bookmark"
                )
            }

            // معاينة المحتوى بحد أقصى أربعة أسطر.
            Text(entry.content)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(4)
                .padding(.top, 4)
        }
        // شكل وخلفية الكرت.
        .padding(16)
        .background(AppColors.surfaceCard)
        .cornerRadius(16)
    }
}
