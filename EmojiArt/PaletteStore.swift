//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by 나동건 on 8/14/24.
//

import SwiftUI

class PaletteStore: Observable, ObservableObject {
    var name: String
    var userDefaultKey: String { "PaletteStoreKey: \(name)" }
    
    init(name: String) {
        self.name = name
        if palettes.isEmpty {
            palettes = Palette.builtins
            if palettes.isEmpty {
                palettes = [Palette(name: "WARNING: palette is empty.", emojis: "⚠️")]
            }
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
    
    // MARK: - Variables
    
    var palettes: Array<Palette> {
        get { UserDefaults.standard.palettes(forKey: userDefaultKey) }
        set {
            if !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: userDefaultKey)
                objectWillChange.send()
            }
        }
    }
    
    var palette: Palette {
        palettes[cursorIndex]
    }
    
    // MARK: - Intents
    
    func remove() -> Void {
        palettes.remove(at: cursorIndex)
    }
}

extension UserDefaults {
    func palettes(forKey key: String) -> Array<Palette> {
        if let jsonData = data(forKey: key),
           let result = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            return result
        } else {
            return []
        }
    }
    
    func set(_ palettes: Array<Palette>, forKey key: String ) {
        if let encoded = try? JSONEncoder().encode(palettes) {
            set(encoded, forKey: key)
        }
    }
}
