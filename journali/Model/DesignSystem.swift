//
//  DesignSystem.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//
import SwiftUI

struct AppColors {
    // Primary & Accents
    static let primaryAccent = Color(hex: "7F81FF")    // Save button, active actions
    static let textAccent = Color(hex: "AF99FD")       // Journal titles, empty-state heading
    
    // Text Colors
    static let textPrimary = Color.white               // Main headings, content (#FFFFFF)[cite: 2]
    static let textSecondary = Color(hex: "A39A9A")     // Subtitles, entry dates[cite: 2]
    
    // Surfaces & Backgrounds
    static let surfaceCard = Color(hex: "1C1C1E")       // Journal cards[cite: 2]
    static let backgroundPrimary = Color.black         // Main screen background (#000000)[cite: 2]
    
    // Semantic
    static let destructive = Color(hex: "FD453C")       // Delete action[cite: 2]
}

// Hex color extension helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x000000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
