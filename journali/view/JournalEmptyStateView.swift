//
//  JournalEmptyStateView.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//

import SwiftUI

struct JournalEmptyStateView: View {
    // إدارة الجورنال والبحث والفرز.
    @StateObject private var viewModel = JournalViewModel()

    // إدارة المايك وتحويل الكلام إلى نص.
    @StateObject private var speechSearch = SpeechSearchViewModel()

    // التحكم بلوحة المفاتيح.
    @FocusState private var isSearchFocused: Bool

    // فتح نافذة الإضافة أو التعديل.
    @State private var showNewJournalSheet = false
    @State private var selectedEntryToEdit: JournalEntry? = nil

    // بيانات تنبيه الحذف.
    @State private var entryToDelete: JournalEntry? = nil
    @State private var showDeleteAlert = false

    // شريط بحث مخصص بخامة النظام وزر المايك.
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)

            TextField("Search", text: $viewModel.searchText)
                .foregroundStyle(AppColors.textPrimary)
                .tint(AppColors.primaryAccent)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isSearchFocused)
                .onSubmit {
                    isSearchFocused = false
                }
                .accessibilityLabel("Search journals")

            // مسح نص البحث.
            if !viewModel.searchText.isEmpty &&
                !speechSearch.isRecording {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textSecondary)
                }
                .accessibilityLabel("Clear search")
            }

            // بدء التسجيل أو إيقافه.
            Button {
                isSearchFocused = false

                Task {
                    await speechSearch.toggleRecording()
                }
            } label: {
                Image(
                    systemName: speechSearch.isRecording
                        ? "stop.circle.fill"
                        : "mic"
                )
                .font(.system(size: 20))
                .foregroundStyle(
                    speechSearch.isRecording
                        ? AppColors.textAccent
                        : AppColors.textSecondary
                )
                .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(speechSearch.isStarting)
            .accessibilityLabel(
                speechSearch.isRecording
                    ? "Stop voice search"
                    : "Start voice search"
            )
        }
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .padding(.vertical, 4)
        .background(.regularMaterial, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(
                    .white.opacity(0.12),
                    lineWidth: 1
                )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // خلفية التطبيق.
                AppColors.backgroundPrimary
                    .ignoresSafeArea()

                if !viewModel.searchText.isEmpty &&
                    viewModel.displayedJournals.isEmpty {
                    // حالة البحث بدون نتائج.
                    ContentUnavailableView {
                        Label(
                            "No Results",
                            systemImage: "magnifyingglass"
                        )
                        .foregroundStyle(AppColors.textAccent)
                    } description: {
                        Text(
                            "No journals found for “\(viewModel.searchText)”. Try a different title or word."
                        )
                        .foregroundStyle(AppColors.textSecondary)
                    }
                } else if viewModel.journals.isEmpty {
                    // شاشة البداية بدون جورنال.
                    VStack(spacing: 16) {
                        Image("Image2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)

                        Text("Begin Your Journal")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.textAccent)

                        Text(
                            "Craft your personal diary, tap the\nplus icon to begin"
                        )
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                } else {
                    // قائمة الجورنال مع دعم السحب.
                    List {
                        ForEach(viewModel.displayedJournals) { entry in
                            JournalCardView(entry: entry) {
                                viewModel.toggleBookmark(for: entry)
                            }
                            .contentShape(Rectangle())

                            // فتح الجورنال للتعديل.
                            .onTapGesture {
                                speechSearch.stopRecording()
                                isSearchFocused = false
                                selectedEntryToEdit = entry
                            }

                            // إظهار زر الحذف عند السحب.
                            .swipeActions(
                                edge: .trailing,
                                allowsFullSwipe: false
                            ) {
                                Button {
                                    speechSearch.stopRecording()
                                    isSearchFocused = false
                                    entryToDelete = entry
                                    showDeleteAlert = true
                                } label: {
                                    Label(
                                        "Delete",
                                        systemImage: "trash.fill"
                                    )
                                }
                                .tint(.red)
                            }

                            // الحفاظ على شكل الكروت.
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 8,
                                    leading: 20,
                                    bottom: 8,
                                    trailing: 20
                                )
                            )
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("Journal")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // خيارات الفرز والبوك مارك.
                    Menu {
                        Button("Sort by Bookmark") {
                            viewModel.sortOption = .bookmark
                        }

                        Button("Sort by Entry Date") {
                            viewModel.sortOption = .entryDate
                        }
                    } label: {
                        Image(
                            systemName: "line.3.horizontal.decrease"
                        )
                    }

                    // إضافة جورنال جديدة.
                    Button {
                        speechSearch.stopRecording()
                        isSearchFocused = false
                        showNewJournalSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            // تثبيت شريط البحث أسفل الشاشة.
            .safeAreaInset(edge: .bottom) {
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }

            // تحويل الكلام إلى بحث مباشر.
            .onChange(of: speechSearch.transcript) { _, newText in
                viewModel.searchText = newText
            }

            // إيقاف المايك عند بدء الكتابة.
            .onChange(of: isSearchFocused) { _, focused in
                if focused {
                    speechSearch.stopRecording()
                }
            }

            // تأكيد الحذف الأصلي من Apple.
            .alert(
                "Delete Journal?",
                isPresented: $showDeleteAlert,
                presenting: entryToDelete
            ) { entry in
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }

                Button("Delete", role: .destructive) {
                    withAnimation {
                        viewModel.deleteJournal(entry)
                    }

                    entryToDelete = nil
                }
            } message: { _ in
                Text(
                    "Are you sure you want to delete this journal?"
                )
            }
        }
        .preferredColorScheme(.dark)

        // إيقاف المايك عند مغادرة الشاشة.
        .onDisappear {
            speechSearch.stopRecording()
        }

        // إيقاف التسجيل عند انتقال التطبيق للخلفية.
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willResignActiveNotification
            )
        ) { _ in
            speechSearch.stopRecording()
        }

        // تنبيه مشاكل الأذونات أو التسجيل.
        .alert(
            "Voice Search",
            isPresented: Binding(
                get: {
                    speechSearch.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        speechSearch.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                speechSearch.errorMessage = nil
            }
        } message: {
            Text(speechSearch.errorMessage ?? "")
        }

        // نافذة إضافة جورنال.
        .sheet(isPresented: $showNewJournalSheet) {
            JournalEditorView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }

        // نافذة تعديل الجورنال المختارة.
        .sheet(item: $selectedEntryToEdit) { entry in
            JournalEditorView(
                viewModel: viewModel,
                entryToEdit: entry
            )
            .preferredColorScheme(.dark)
        }
    }
}

// معاينة الواجهة.
#Preview {
    JournalEmptyStateView()
}
