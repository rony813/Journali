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
    @AppStorage("saved_journals_data")
    private var savedJournalsData: Data = Data()

    @Published var journals: [JournalEntry] = [] {
        // يحفظ البيانات تلقائيًا عند الإضافة أو التعديل أو الحذف.
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

    var displayedJournals: [JournalEntry] {
        let filtered = searchText.isEmpty ? journals : journals.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOption {
        case .entryDate:
            // يعرض كل الجورنال، الأحدث أولًا.
            return filtered.sorted {
                $0.date > $1.date
            }

        case .bookmark:
            // يحافظ على تعديلنا السابق:
            // يعرض فقط الجورنال اللي عليها بوك مارك، الأحدث أولًا.
            return filtered
                .filter { $0.isBookmarked }
                .sorted { $0.date > $1.date }
        }
    }

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

    func toggleBookmark(for entry: JournalEntry) {
        if let index = journals.firstIndex(where: {
            $0.id == entry.id
        }) {
            journals[index].isBookmarked.toggle()
            objectWillChange.send()
        }
    }

    // جديد: يحذف الجورنال المطلوبة باستخدام معرّفها الفريد.
    // نستخدم id عشان نحذف العنصر الصحيح حتى أثناء البحث أو الفلترة.
    func deleteJournal(_ entry: JournalEntry) {
        journals.removeAll {
            $0.id == entry.id
        }

        // ما نحتاج نستدعي الحفظ هنا؛
        // تغيير journals يشغّل didSet ويحفظ النتيجة تلقائيًا.
    }

    private func saveToAppStorage() {
        if let encoded = try? JSONEncoder().encode(journals) {
            savedJournalsData = encoded
        }
    }

    private func loadFromAppStorage() {
        if let decoded = try? JSONDecoder().decode(
            [JournalEntry].self,
            from: savedJournalsData
        ) {
            journals = decoded
        }
    }
}
