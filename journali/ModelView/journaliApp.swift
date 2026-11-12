//
//  journaliApp.swift
//  journali
//
//  Created by RON on 29/05/1448 AH.
//

import SwiftUI

@main
struct JournalApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                // Force dark mode appearance app-wide
                .preferredColorScheme(.dark)
        }
    }
}

