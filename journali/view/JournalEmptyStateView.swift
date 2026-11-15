//
//  JournalEmptyStateView.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//

import SwiftUI

struct JournalEmptyStateView: View {
    @StateObject private var viewModel = JournalViewModel()
    
    @State private var showNewJournalSheet = false
    @State private var selectedEntryToEdit: JournalEntry? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                if viewModel.journals.isEmpty {
                    VStack(spacing: 16) {
                        Image("Image2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                        
                        Text("Begin Your Journal")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.textAccent)
                        
                        Text("Craft your personal diary, tap the\nplus icon to begin")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.displayedJournals) { entry in
                                JournalCardView(entry: entry) {
                                    viewModel.toggleBookmark(for: entry)
                                }
                                .onTapGesture {
                                    selectedEntryToEdit = entry
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Journal")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                // أزرار أبل الصافية بدون أي HStack أو خلفيات يدوية عشان يرسمها النظام بنفسه
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { viewModel.sortOption = .bookmark }) {
                            Label("Sort by Bookmark", systemImage: viewModel.sortOption == .bookmark ? "checkmark" : "")
                        }
                        
                        Button(action: { viewModel.sortOption = .entryDate }) {
                            Label("Sort by Entry Date", systemImage: viewModel.sortOption == .entryDate ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    
                    Button(action: {
                        showNewJournalSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // شريط البحث الرسمي (في iOS 26 ينزل للأسفل تلقائياً مثل الصورة المرجعية)
            .searchable(text: $viewModel.searchText, prompt: "Search")
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showNewJournalSheet) {
            JournalEditorView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $selectedEntryToEdit) { entry in
            JournalEditorView(viewModel: viewModel, entryToEdit: entry)
                .preferredColorScheme(.dark)
        }
    }
}
#Preview {
    JournalEmptyStateView()
}
