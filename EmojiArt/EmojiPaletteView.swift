//
//  EmojiPaletteView.swift
//  EmojiArt
//
//  Created by 나동건 on 8/14/24.
//

import SwiftUI

struct PaletteView: View {
    @EnvironmentObject var paletteStore: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: paletteStore)
        }
        .clipped()
    }
    
    var chooser: some View {
        ActionButton(image: "paintpalette") {
            withAnimation {
                paletteStore.cursorIndex += 1
            }
        }
        .contextMenu {
            ActionButton(title: "Delete", image: "trash", role: .destructive) {
                withAnimation {
                    paletteStore.remove()
                }
            }
        }
    }
    
    func view(for paletteStore: PaletteStore) -> some View {
        HStack {
            Text(paletteStore.palette.name)
            EmojiPalette(emojis: paletteStore.palette.emojis)
        }
        .id(paletteStore.palettes[paletteStore.cursorIndex].id)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
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

#Preview {
    PaletteView()
        .environment(PaletteStore(name: "PalettePreView"))
}
