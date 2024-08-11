//
//  ContentView.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌞🌎🔥🌈🌧️🌨️☁️⛄️⛳️🚗🚙🚓🚲🛺🏍️🚘✈️🛩️🚀🚁🏰🏠❤️💤⛵️"
    
    @ObservedObject var document: EmojiArtDocument
    
    private let paleteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack {
            documentBody
            
            EmojiPalette(emojis: emojis)
                .font(Font.system(size: paleteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                
                AsyncImage(url: document.background)
                
                ForEach(document.emojis) { emoji in
                    Text(emoji.emoji)
                        .position(emoji.position.in(geometry: geometry ))
                        .font(emoji.font)
                }
            }
            .dropDestination(for: Sturldata.self) { Sturldatas, location in
                return drop(Sturldatas, at: location, in: geometry)
            }
        }
    }
    
    private func drop(
        _ sturldatas: Array<Sturldata>,
        at location: CGPoint,
        in geomtry: GeometryProxy
    ) -> Bool {
        for sturldata in sturldatas {
            switch(sturldata) {
            case .url(let url):
                document.setBackground(url: url)
                return true
            case .string(let emoji):
                document.addEmoji(emoji: emoji, position: emojiPosition(at: location, in: geomtry), size: paleteEmojiSize)
                return true
            default:
                return false
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center()
        return Emoji.Position(
            x: Int(location.x - center.x),
            y: Int(-(location.y - center.y))
        )
    }
}

struct EmojiPalette: View  {
    let emojis: Array<String>
    
    init(emojis: String ) {
        self.emojis = emojis.unique()
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}


extension String {
    func unique() -> Array<String> {
        return self.reduce(into: []) { sofar, char in
            if !sofar.contains(String(char)) {
                sofar.append(String(char))
            }
        }
    }
}

extension CGRect {
    func center() -> CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}


