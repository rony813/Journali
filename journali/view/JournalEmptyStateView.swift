//
//  JournalEmptyStateView.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//

import SwiftUI

struct JournalEmptyStateView: View {
    // Journal data, sorting, and searching.
    @StateObject private var viewModel = JournalViewModel()

    // Microphone and speech recognition.
    @StateObject private var speechSearch = SpeechSearchViewModel()

    @FocusState private var isSearchFocused: Bool

    // Create and edit sheets.
    @State private var showNewJournalSheet = false
    @State private var selectedEntryToEdit: JournalEntry? = nil

    // Delete confirmation.
    @State private var entryToDelete: JournalEntry? = nil
    @State private var showDeleteAlert = false

    // Search bar with voice search.
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

            // Clear the search text.
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

            // Start or stop voice search.
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
                AppColors.backgroundPrimary
                    .ignoresSafeArea()

                if !viewModel.searchText.isEmpty &&
                    viewModel.displayedJournals.isEmpty {
                    // Search has no matching entries.
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
                    // No entries have been created.
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
                } else if viewModel.sortOption == .bookmarkedOnly &&
                            viewModel.displayedJournals.isEmpty {
                    // The bookmark-only filter has no entries.
                    ContentUnavailableView {
                        Label(
                            "No Bookmarked Journals",
                            systemImage: "bookmark"
                        )
                        .foregroundStyle(AppColors.textAccent)
                    } description: {
                        Text(
                            "Bookmark a journal to see it here."
                        )
                        .foregroundStyle(AppColors.textSecondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.displayedJournals) { entry in
                            // Journal card and bookmark action.
                            JournalCardView(entry: entry) {
                                viewModel.toggleBookmark(for: entry)
                            }
                            .contentShape(Rectangle())

                            // Open the selected entry.
                            .onTapGesture {
                                speechSearch.stopRecording()
                                isSearchFocused = false
                                selectedEntryToEdit = entry
                            }

                            // Reveal the delete button by swiping.
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

                            // Preserve the card appearance.
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
                    // Native sorting and filtering menu.
                    Menu {
                        Button("Sort by Bookmark") {
                            viewModel.sortOption = .bookmark
                        }

                        Button("Sort by Entry Date") {
                            viewModel.sortOption = .entryDate
                        }

                        // New: show bookmarked entries only.
                        Button("Show Bookmarked Only") {
                            viewModel.sortOption = .bookmarkedOnly
                        }
                    } label: {
                        Image(
                            systemName: "line.3.horizontal.decrease"
                        )
                    }

                    // Create a new entry.
                    Button {
                        speechSearch.stopRecording()
                        isSearchFocused = false
                        showNewJournalSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            // Keep the search bar at the bottom.
            .safeAreaInset(edge: .bottom) {
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }

            // Update search results while speaking.
            .onChange(of: speechSearch.transcript) { _, newText in
                viewModel.searchText = newText
            }

            // Stop recording when typing begins.
            .onChange(of: isSearchFocused) { _, focused in
                if focused {
                    speechSearch.stopRecording()
                }
            }

            // Native delete confirmation.
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

        // Stop recording when leaving the screen.
        .onDisappear {
            speechSearch.stopRecording()
        }

        // Stop recording when the app becomes inactive.
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willResignActiveNotification
            )
        ) { _ in
            speechSearch.stopRecording()
        }

        // Display voice-search errors.
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

        // New-entry sheet.
        .sheet(isPresented: $showNewJournalSheet) {
            JournalEditorView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }

        // Edit-entry sheet.
        .sheet(item: $selectedEntryToEdit) { entry in
            JournalEditorView(
                viewModel: viewModel,
                entryToEdit: entry
            )
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    JournalEmptyStateView()
}
