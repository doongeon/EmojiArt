//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import Foundation
import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
        }
    }
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autoSavedEmojiArt = try? EmojiArt(json: data) {
            emojiArt = autoSavedEmojiArt
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("autosaved.emojiart")
    
    private func autosave() -> Void {
        save(to: autosaveURL)
    }
    
    private func save(to url : URL) -> Void {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
    }
    
    var background: URL? {
        emojiArt.url
    }
    
    var emojis: Array<Emoji > {
        emojiArt.emojis
    }
    
    func scaleEmoji(id: Emoji.ID, scale: CGFloat) -> Void {
        emojiArt.scaleEmoji(id: id, scale: Double(scale))
    }
    
    func panEmoji(id: Emoji.ID, offset: CGOffset) -> Void {
        emojiArt.panEmoji(id: id, offset: Offset(x: offset.width, y: -offset.height))
    }
    
    // MARK: - Intents
    
    func setBackground (url: URL) -> Void {
        emojiArt.setBackground(url: url)
    }
    
    func addEmoji(emoji: String, position: Emoji.Position, size: CGFloat) -> Void {
        emojiArt.addEmoji(emoji: emoji, position: position, size: Double(size))
    }
    
    func removeEmoji(emoji: Emoji) -> Void {
        emojiArt.removeEmoji(id: emoji.id)
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center()
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
