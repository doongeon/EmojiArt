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
    
    @Published private var emojiArt = EmojiArt()
    
    var background: URL? {
        emojiArt.url
    }
    
    var emojis: Array<Emoji > {
        emojiArt.emojis
    }
    
    // MARK: - Intents
    
    func setBackground (url: URL) -> Void {
        emojiArt.setBackground(url: url)
    }
    
    func updateEmojiSize(id: Emoji.ID, to size: CGFloat) -> Void {
        emojiArt.emojis
    }
    
    func addEmoji(emoji: String, position: Emoji.Position, size: CGFloat) -> Void {
        emojiArt.addEmoji(emoji: emoji, position: position, size: Int(size))
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
