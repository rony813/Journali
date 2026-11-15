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
}

class JournalViewModel: ObservableObject {
    // Stores all journals directly in device memory
    @AppStorage("saved_journals_data") private var savedJournalsData: Data = Data()
    
    @Published var journals: [JournalEntry] = [] {
        didSet {
            saveToAppStorage()
        }
    }
    
    @Published var sortOption: SortOption = .entryDate
    @Published var searchText: String = ""
    
    init() {
        loadFromAppStorage()
    }
    
    // Returns journals filtered by search and sorted by the user's choice
    var displayedJournals: [JournalEntry] {
        let filtered = searchText.isEmpty ? journals : journals.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .entryDate:
            return filtered.sorted { $0.date > $1.date }
        case .bookmark:
            return filtered.sorted {
                if $0.isBookmarked == $1.isBookmarked {
                    return $0.date > $1.date
                }
                return $0.isBookmarked && !$1.isBookmarked
            }
        }
    }
    
    // MARK: - Actions
    func saveJournal(existing: JournalEntry?, title: String, content: String) {
        if let existing = existing, let index = journals.firstIndex(where: { $0.id == existing.id }) {
            journals[index].title = title
            journals[index].content = content
        } else {
            let newEntry = JournalEntry(title: title, content: content)
            journals.append(newEntry)
        }
    }
    
    func toggleBookmark(for entry: JournalEntry) {
        if let index = journals.firstIndex(where: { $0.id == entry.id }) {
            journals[index].isBookmarked.toggle()
        }
    }
    
    // MARK: - @AppStorage Encoding / Decoding
    private func saveToAppStorage() {
        if let encoded = try? JSONEncoder().encode(journals) {
            savedJournalsData = encoded
        }
    }
    
    private func loadFromAppStorage() {
        if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: savedJournalsData) {
            journals = decoded
        }
    }
}
