//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import Foundation

struct EmojiArt: Codable {
    var url: URL?
    private(set) var emojis = [Emoji]()
    private var uniqueEmojiId = 0
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    init() {}
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self)
        print("EmojiArt Encoded: \(String(data: encoded, encoding: .utf8) ?? "nil")")
        return encoded
    }
    
    mutating func setBackground(url: URL) -> Void {
        self.url = url 
    }
    
    mutating func addEmoji(emoji: String, position: Emoji.Position, size: Double ) {
        emojis.append(Emoji(id: uniqueEmojiId, emoji: emoji, position: position, size: size))
        uniqueEmojiId += 1
    }
    
    mutating func removeEmoji(id: Emoji.ID) -> Void {
        if let indexOfEmoji = emojis.firstIndex(where: {$0.id == id}) {
            emojis.remove(at: indexOfEmoji)
        }
    }
    
    mutating func scaleEmoji(id: Emoji.ID, scale: Double) -> Void {
        if let emojiIndex = emojis.firstIndex(where: { $0.id == id  }) {
            emojis[emojiIndex].scaleSize(scale: scale)
        }
    }
    
    mutating func panEmoji(id: Emoji.ID, offset: Offset) -> Void {
        if let emojiIndex = emojis.firstIndex(where: {$0.id == id}) {
            emojis[emojiIndex].move(offset: offset)
        }
    }
    
    struct Emoji: Identifiable, Codable {
        var id: Int
        let emoji: String
        var position: Position
        var size: Double
        
        struct Position: Codable {
            var x: Double
            var y: Double
            
            static var zero: Position {
                Position(x: 0, y: 0)
            }
        }
        
        mutating func scaleSize(scale: Double) -> Void {
            size *= scale
        }
        
        mutating func move(offset: Offset) -> Void {
            position.x += offset.x
            position.y += offset.y
        }
    }
}

struct Offset {
    let x: Double
    let y: Double
}
