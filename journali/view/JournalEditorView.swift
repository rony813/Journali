//
//  JournalEditorView.swift
//  journali
//
//  Created by RON on 02/06/1448 AH.
//

import SwiftUI

struct JournalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    var entryToEdit: JournalEntry?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var showDiscardAlert = false
    
    private var hasUnsavedChanges: Bool {
        if let existing = entryToEdit {
            return title != existing.title || content != existing.content
        }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var displayDate: String {
        if let existing = entryToEdit {
            return existing.formattedDate
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.surfaceCard
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Title", text: $title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .tint(AppColors.primaryAccent)
                    
                    Text(displayDate)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Type your Journal...")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $content)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .tint(AppColors.primaryAccent)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // زر الإغلاق الرسمي من أبل
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        if hasUnsavedChanges {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                
                // زر الحفظ الرسمي باللون البنفسجي
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : title
                        viewModel.saveJournal(existing: entryToEdit, title: finalTitle, content: content)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryAccent)
                }
            }
        }
        // إظهار مؤشر السحب العلوي الرسمي من أبل
        .presentationDragIndicator(.visible)
        .alert("Are you sure you want to discard changes on this journal?", isPresented: $showDiscardAlert) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) { }
        }
        .onAppear {
            if let existing = entryToEdit {
                title = existing.title
                content = existing.content
            }
        }
    }
}
