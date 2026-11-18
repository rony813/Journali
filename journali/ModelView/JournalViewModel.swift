//
//  JournalViewModel.swift
//  journali
//
//  Created by RON on 02/06/1448 AH.
//

import SwiftUI
import Combine

enum SortOption {
    case entryDate
    case bookmark
    case bookmarkedOnly
}

class JournalViewModel: ObservableObject {
    // Store journal data locally.
    @AppStorage("saved_journals_data")
    private var savedJournalsData: Data = Data()

    @Published var journals: [JournalEntry] = [] {
        // Save automatically when entries change.
        didSet {
            saveToAppStorage()
        }
    }

    @Published var sortOption: SortOption = .entryDate {
        didSet {
            objectWillChange.send()
        }
    }

    @Published var searchText: String = "" {
        didSet {
            objectWillChange.send()
        }
    }

    init() {
        loadFromAppStorage()
    }

    // Apply search, then the selected sorting or filtering option.
    var displayedJournals: [JournalEntry] {
        let filtered = searchText.isEmpty ? journals : journals.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOption {
        case .entryDate:
            // Show all matching entries, newest first.
            return filtered.sorted {
                $0.date > $1.date
            }

        case .bookmark:
            // Show all matching entries, bookmarked entries first.
            return filtered.sorted {
                if $0.isBookmarked != $1.isBookmarked {
                    return $0.isBookmarked
                }

                return $0.date > $1.date
            }

        case .bookmarkedOnly:
            // Show bookmarked entries only, newest first.
            // Other entries remain saved.
            return filtered
                .filter { $0.isBookmarked }
                .sorted { $0.date > $1.date }
        }
    }

    // Create an entry or update an existing one.
    func saveJournal(
        existing: JournalEntry?,
        title: String,
        content: String
    ) {
        if let existing = existing,
           let index = journals.firstIndex(where: {
               $0.id == existing.id
           }) {
            journals[index].title = title
            journals[index].content = content
        } else {
            let newEntry = JournalEntry(
                title: title,
                content: content
            )

            journals.insert(newEntry, at: 0)
        }
    }

    // Add or remove a bookmark.
    func toggleBookmark(for entry: JournalEntry) {
        if let index = journals.firstIndex(where: {
            $0.id == entry.id
        }) {
            journals[index].isBookmarked.toggle()
            objectWillChange.send()
        }
    }

    // Permanently delete the selected entry.
    func deleteJournal(_ entry: JournalEntry) {
        journals.removeAll {
            $0.id == entry.id
        }
    }

    // Encode entries and save them locally.
    private func saveToAppStorage() {
        if let encoded = try? JSONEncoder().encode(journals) {
            savedJournalsData = encoded
        }
    }

    // Restore saved entries.
    private func loadFromAppStorage() {
        if let decoded = try? JSONDecoder().decode(
            [JournalEntry].self,
            from: savedJournalsData
        ) {
            journals = decoded
        }
    }
}
