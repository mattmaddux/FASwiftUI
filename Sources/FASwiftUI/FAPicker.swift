//
//  FontAwesomePicker.swift
//  link-swiftui
//
//  Created by Matt Maddux on 9/30/19.
//  Copyright © 2019 Matt Maddux. All rights reserved.
//

import SwiftUI
import QGrid

#if os(iOS)

struct FASearchBar: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var query: String
    var clearAction: () -> Void
    
    var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.gray)
                TextField("Search", text: $query)
                    .padding(.vertical, 5)
                    .disableAutocorrection(true)
                if query.count > 0 {
                    Button(action: clearAction ) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.gray)
                    }
                }
            }
            .padding(.horizontal, 10)
            .background(self.colorScheme == .light ? Color.black.opacity(0.12) : Color.white.opacity(0.12))
            .cornerRadius(8)
    }
}

struct FAPickerCell: View {
    
    var icon: FAIcon
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            Button(action: action) {
                FAText(iconName: icon.id!, size: 35)
                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    .frame(width: 55, height: 55)
            }
        }
        .cornerRadius(5)
    }
}

public struct FAPicker: View {
    
    @ObservedObject var search: FASearchHolder = FASearchHolder()
    @Binding var showing: Bool
    @Binding var selected: String?
    
    public init(showing: Binding<Bool>, selected: Binding<String?>) {
        self._showing = showing
        self._selected = selected
    }
    
    public var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                FASearchBar(query: self.$search.searchQuery, clearAction: self.search.clear)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                if self.search.searchResults != nil && self.search.searchResults!.count > 0 {
                    QGrid(self.search.searchResults!.values.sorted(),
                          columns: 6,
                          vSpacing: 20,
                          hSpacing: 10,
                          vPadding: 10,
                          hPadding: 10) { icon in
                            FAPickerCell(icon: icon, action: {
                                self.selected = icon.id
                                self.showing = false
                            })
                    }
                } else if self.search.searchResults != nil && self.search.searchResults!.count == 0{
                    Spacer()
                    Text("Nothing found")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Spacer()
                } else {
                    Spacer()
                    Text("Search for icons above")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Spacer()
                }
            }
            .navigationBarTitle("Icon Search", displayMode: .inline)
        }
    }

}

#endif
