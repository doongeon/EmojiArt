//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import Foundation

struct EmojiArt {
    var url: URL?
    private(set) var emojis = [Emoji]()
    var uniqueEmojiId = 0
    
    mutating func setBackground(url: URL) -> Void {
        self.url = url 
    }
    
    mutating func addEmoji(emoji: String, position: Emoji.Position, size: Int ) {
        emojis.append(Emoji(id: uniqueEmojiId, emoji: emoji, position: position, size: size))
        uniqueEmojiId += 1
    }
    
    struct Emoji: Identifiable {
        var id: Int
        let emoji: String
        var position: Position
        var size: Int
        
        struct Position {
            var x: Int
            var y: Int 
        }
    }
}
