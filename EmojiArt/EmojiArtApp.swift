//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(name: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
                .environment(paletteStore)
        }
    }
}
