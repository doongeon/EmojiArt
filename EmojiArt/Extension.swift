//
//  Extension.swift
//  EmojiArt
//
//  Created by 나동건 on 8/14/24.
//

import Foundation
import SwiftUI

// custom type CGOffset
//
typealias CGOffset = CGSize

extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
}
//
//


//
//
extension String {
    func unique() -> Array<String> {
        return self.reduce(into: []) { sofar, char in
            if !sofar.contains(String(char)) {
                sofar.append(String(char))
            }
        }
    }
}
//
//

//
//
extension CGRect {
    func center() -> CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
//
//

//
// custom buttons
//
struct ActionButton: View {
    let title: String?
    let image: String?
    let role: ButtonRole?
    let action: () -> Void
    
    init(
        title: String? = nil,
        image: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            action()
        } label: {
            if let title, let image {
                HStack {
                    Text(title)
                    Image(systemName: image)
                }
            } else if let title {
                Text(title)
            } else if let image {
                Image(systemName: image)
            }
        }
    }
}
//
//
//

