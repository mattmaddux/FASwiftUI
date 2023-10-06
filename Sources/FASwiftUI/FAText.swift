//
//  FAText.swift
//  link-swiftui
//
//  Created by Matt Maddux on 10/1/19.
//  Copyright © 2019 Matt Maddux. All rights reserved.
//

import SwiftUI

public struct FAText: View {
    
    var iconName: String
    private var icon: FAIcon
    var size: CGFloat
    var style: FAStyle
    private var weight: Font.Weight {
        return style.weight
    }
    
    public init(iconName: String, size: CGFloat, style: FAStyle? = nil) {
        self.size = size
        self.style = style ?? .regular
        self.iconName = iconName.hasPrefix("fa-") ? String(iconName.dropFirst(3)) : iconName
        
        if let icon = FontAwesome.shared.icon(byName: self.iconName) {
            self.icon = icon
        }
        
        if !self.icon.styles.contains(self.style) {
            let fallbackStyle = self.icon.styles.first!
            if fallbackStyle != .brands && style != nil {
                print("FASwiftUI: Style \"\(style ?? .regular)\" not available for icon \"\(iconName)\", using \"\(fallbackStyle)\". Check list at https://fontawesome.com/icons for set availability.")
            } else if self.style != .regular && style != nil {
                print("FASwiftUI: Icon \"\(iconName)\" is part of the brands set and doesn't support alternate styles. Check list at https://fontawesome.com/icons for set availability.")
            }
            self.style = fallbackStyle
        }
    }
    
    public var body: some View {
        Text(icon.unicodeString)
            .font(Font.custom(icon.collection.rawValue, size: size))
            .fontWeight(weight)
    }
}
