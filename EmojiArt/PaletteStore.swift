//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by 나동건 on 8/14/24.
//

import SwiftUI

class PaletteStore: Observable, ObservableObject {
    var name: String
    
    @Published var palettes: Array<Palette> {
        didSet {
            if palettes.isEmpty {
                palettes = oldValue
            }
        }
    }
    
    var palette: Palette {
        palettes[cursorIndex]
    }
    
    init(name: String) {
        self.name = name
        palettes = Palette.builtins
        if palettes.isEmpty {
            palettes = [Palette(name: "WARNING: palette is empty.", emojis: "⚠️")]
        }
    }
    
    @Published private var _cursorIndex: Int = 0
    
    var cursorIndex: Int {
        set { _cursorIndex = checkIndexBound(index: newValue)}
        get { checkIndexBound(index: _cursorIndex) }
    }
    
    private func checkIndexBound(index: Int) -> Int {
        var checkedIndex = index % palettes.count
        if checkedIndex < 0 {
            checkedIndex += palettes.count
        }
        
        return checkedIndex
    }
    
    func remove() -> Void {
        palettes.remove(at: cursorIndex)
    }
}
