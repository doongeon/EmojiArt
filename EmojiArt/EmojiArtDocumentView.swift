//
//  ContentView.swift
//  EmojiArt
//
//  Created by 나동건 on 8/11/24.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    private let paleteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack {
            documentBody
            PaletteView()
                .font(Font.system(size: paleteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
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
    
    @State private var selectedImoji: Set<Emoji.ID> = Set()
    
    @State private var zoomScale: CGFloat = 1
    @State private var panOffset: CGOffset = .zero
    
    @GestureState private var gestureZoomScale: CGFloat = 1
    @GestureState private var gesturePanOffset: CGOffset = .zero
    
    var zoomGesture: some Gesture {
        if selectedImoji.isEmpty {
            MagnifyGesture()
                .updating($gestureZoomScale) { updatingScale, gestureZoomScale, _ in
                    gestureZoomScale = updatingScale.magnification
                }
                .onEnded { endedScale in
                    zoomScale *= endedScale.magnification
                }
        } else {
            MagnifyGesture()
                .onEnded { enedeSclae in
                    for id in selectedImoji {
                        document.emojis.fi
                    }
                }
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
                .background(selectedImoji.contains(emoji.id) ? .blue : .clear)
                .position(emoji.position.in(geometry: geometry ))
                .font(emoji.font)
                .onTapGesture {
                    withAnimation {
                        if !selectedImoji.contains(emoji.id) {
                            selectedImoji.insert(emoji.id)
                        } else {
                            selectedImoji.remove(emoji.id)
                        }
                    }
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

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environment(PaletteStore(name: "EmojiArtDocumentPreview"))
}


