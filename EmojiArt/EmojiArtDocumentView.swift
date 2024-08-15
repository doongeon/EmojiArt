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
                    .onTapGesture {
                        withAnimation {
                            selectedImoji = Set()
                        }
                    }
            }
            .dropDestination(for: Sturldata.self) { Sturldatas, location in
                return drop(Sturldatas, at: location, in: geometry)
            }
            .gesture(
                panGesture.simultaneously(
                    with: selectedImoji.isEmpty ? zoomGesture : nil
                ).simultaneously(
                    with: !selectedImoji.isEmpty ? emojiZoomGesture : nil
                )
            )
        }
    }
    
    
    //
    // Emoji gesture
    //
    @State private var selectedImoji: Set<Emoji.ID> = Set()
    
    @GestureState private var gestureZoomScale: CGFloat = 1
    @GestureState private var gestureEmojiOffset: CGOffset = .zero
    
    var emojiPanGesture: some Gesture {
        DragGesture()
            .updating ($gestureEmojiOffset) { value, gestureEmojiOffset, _ in
                gestureEmojiOffset = value.translation
            }
            .onEnded { value in
                for id in selectedImoji {
                    document.panEmoji(id: id, offset: value.translation)
                }
            }
    }
    
    var emojiZoomGesture: some Gesture {
        MagnifyGesture()
            .updating($gestureEmojiZoomScale) { updatingScale, gestureEmojiZoomScale, _ in
                gestureEmojiZoomScale = updatingScale.magnification
            }
            .onEnded { endedScale in
                for id in selectedImoji {
                    document.scaleEmoji(id: id, scale: endedScale.magnification)
                }
            }
    }
    //
    //
    //
    
    
    //
    // Document gesture
    //
    @State private var zoomScale: CGFloat = 1
    @State private var panOffset: CGOffset = .zero
    
    @GestureState private var gestureEmojiZoomScale: CGFloat = 1
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
    //
    //
    //
    
    
    @ViewBuilder
    func documentContent(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.zero.in(geometry: geometry))
        ForEach(document.emojis) { emoji in
            view(for: emoji, in: geometry)
                .offset(dragedEmojiId == emoji.id ? imojiDragOffset : .zero)
                .onTapGesture {
                    withAnimation {
                        if !selectedImoji.contains(emoji.id) {
                            selectedImoji.insert(emoji.id)
                        } else {
                            selectedImoji.remove(emoji.id)
                        }
                    }
                }
                .gesture(selectedImoji.contains(emoji.id) ? emojiPanGesture : nil )
                .gesture(imojiDrageGesture(emoji: emoji, in: geometry))
        }
    }
    
    @GestureState var imojiDragOffset: CGOffset = .zero
    @State var dragedEmojiId: Emoji.ID? = nil
    
    func imojiDrageGesture(emoji: Emoji, in geometyr: GeometryProxy) -> some Gesture {
        return DragGesture()
            .onChanged { _ in
                dragedEmojiId = emoji.id
            }
            .updating( $imojiDragOffset) { value, imojiDragOffset, _ in
                imojiDragOffset = value.translation
            }
            .onEnded { value in
                document.panEmoji(id: emoji.id, offset: value.translation)
                dragedEmojiId = nil
            }
    }
    
    func view(for emoji: Emoji, in geometry: GeometryProxy) -> some View {
        Text(emoji.emoji)
            .border(selectedImoji.contains(emoji.id) ? .blue : .clear)
            .offset(selectedImoji.contains(emoji.id) ? gestureEmojiOffset : .zero )
            .font(
                .system(
                    size: CGFloat(emoji.size) * (
                        selectedImoji.contains(emoji.id) ? gestureEmojiZoomScale : 1)
                )
            )
            .contextMenu {
                ActionButton(title: "Delete", image: "trash", role: .destructive) {
                    document.removeEmoji(emoji: emoji)
                }
            }
            .position(emoji.position.in(geometry: geometry))
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
                document.addEmoji(
                    emoji: emoji,
                    position: emojiPosition(at: location, in: geomtry),
                    size: paleteEmojiSize / zoomScale)
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
            x: Double ((location.x - center.x - panOffset.width) / zoomScale),
            y: Double (-(location.y - center.y - panOffset.height) / zoomScale)
        )
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environment(PaletteStore(name: "EmojiArtDocumentPreview"))
}


