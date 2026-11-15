//
//  JournalEntry.swift
//  journali
//
//  Created by RON on 02/06/1448 AH.
//

import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var date: Date = Date()
    var isBookmarked: Bool = false
    
    // Formats date as DD/MM/YYYY matching your design (e.g., 02/09/2024)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
