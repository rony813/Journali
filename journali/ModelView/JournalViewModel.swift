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
    // تخزين الجورنال محليًا.
    @AppStorage("saved_journals_data")
    private var savedJournalsData: Data = Data()

    @Published var journals: [JournalEntry] = [] {
        // حفظ البيانات عند الإضافة أو التعديل أو الحذف.
        didSet {
            saveToAppStorage()
        }
    }

    // خيار ترتيب الجورنال.
    @Published var sortOption: SortOption = .entryDate {
        didSet {
            objectWillChange.send()
        }
    }

    // نص البحث.
    @Published var searchText: String = "" {
        didSet {
            objectWillChange.send()
        }
    }

    init() {
        loadFromAppStorage()
    }

    // تجهيز نتائج البحث وترتيبها للعرض.
    var displayedJournals: [JournalEntry] {
        let filtered = searchText.isEmpty ? journals : journals.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOption {
        case .entryDate:
            // عرض الجورنال من الأحدث إلى الأقدم.
            return filtered.sorted {
                $0.date > $1.date
            }

        case .bookmark:
            // عرض الكل، والجورنال اللي عليها بوك مارك أولًا.
            return filtered.sorted {
                if $0.isBookmarked != $1.isBookmarked {
                    return $0.isBookmarked
                }

                // الأحدث أولًا داخل كل مجموعة.
                return $0.date > $1.date
            }
        }
    }

    // إضافة جورنال جديدة أو تعديل الموجودة.
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

    // إضافة البوك مارك أو إزالته.
    func toggleBookmark(for entry: JournalEntry) {
        if let index = journals.firstIndex(where: {
            $0.id == entry.id
        }) {
            journals[index].isBookmarked.toggle()
            objectWillChange.send()
        }
    }

    // حذف الجورنال باستخدام معرّفها.
    func deleteJournal(_ entry: JournalEntry) {
        journals.removeAll {
            $0.id == entry.id
        }
    }

    // تحويل البيانات إلى JSON وحفظها.
    private func saveToAppStorage() {
        if let encoded = try? JSONEncoder().encode(journals) {
            savedJournalsData = encoded
        }
    }

    // استرجاع الجورنال المحفوظة.
    private func loadFromAppStorage() {
        if let decoded = try? JSONDecoder().decode(
            [JournalEntry].self,
            from: savedJournalsData
        ) {
            journals = decoded
        }
    }
}
