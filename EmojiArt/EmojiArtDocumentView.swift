//
//  ContentView.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    var mySturldata = Sturldata(string: "https://i1.daumcdn.net/thumb/C100x100/?scode=mtistory2&fname=https%3A%2F%2Ftistory1.daumcdn.net%2Ftistory%2F6840637%2Fattach%2F1e40792b205541e0b0e2604fa7a48a81")
    
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
        .onAppear {
            print(mySturldata)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContent(in: geometry)
                    .scaleEffect(zoomScale * gestureZoomScale)
                    .offset(panOffset + gesturePanOffset)
            }
            .dropDestination(for: Sturldata.self) { Sturldatas, location in
                return drop(Sturldatas, at: location, in: geometry)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
        }
    }
    
    @State private var zoomScale: CGFloat = 1
    @State private var panOffset: CGOffset = .zero
    
    @GestureState private var gestureZoomScale: CGFloat = 1
    @GestureState private var gesturePanOffset: CGOffset = .zero
    
    var zoomGesture: some Gesture {
        MagnifyGesture()
            .updating($gestureZoomScale) { updatingScale, gestureZoomScale, _ in
                gestureZoomScale = updatingScale.magnification
            }
            .onEnded { endedScale in
                zoomScale *= endedScale.magnification
            }
    }
    
    var panGesture: some Gesture {
        DragGesture()
            .updating ($gesturePanOffset) { value, gesturePanOffset, _ in
                gesturePanOffset = value.translation
            }
            .onEnded { value in
                panOffset += value.translation
            }
    }
    
    @ViewBuilder
    func documentContent(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
        
        ForEach(document.emojis) { emoji in
            Text(emoji.emoji)
                .position(emoji.position.in(geometry: geometry ))
                .font(emoji.font)
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
                document.addEmoji(emoji: emoji, position: emojiPosition(at: location, in: geomtry), size: paleteEmojiSize / zoomScale)
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
            x: Int((location.x - center.x - panOffset.width) / zoomScale),
            y: Int(-(location.y - center.y - panOffset.height) / zoomScale)
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

typealias CGOffset = CGSize
extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
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


