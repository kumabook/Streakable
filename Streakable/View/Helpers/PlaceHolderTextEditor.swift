//
//  PlaceHolderTextEditor.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/04.
//

import SwiftUI

struct PlaceHolderTextEditor: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(LocalizedStringKey(placeholder))
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.top, 8)
            }
            TextEditor(text: $text)
                .scrollContentBackground(Visibility.hidden)
                .padding(.leading, -4)
               
        }.frame(minHeight: 60, maxHeight: 180)
    }
}

#Preview {
    PlaceHolderTextEditor(text: .constant("test"), placeholder: "placeholder")
}
