//
//  MultiSelectionView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/06/08.
//

import SwiftUI
import SwiftUI

struct MultiSelectionView<Selectable: MultiSelectable>: View {
    let options: [Selectable]

    @Binding
    var selected: [Selectable]
    
    var body: some View {
        List {
            ForEach(options) { selectable in
                Button(action: { toggleSelection(selectable: selectable) }) {
                    HStack {
                        Text(selectable.title).foregroundColor(.black)

                        Spacer()

                        if selected.contains(where: { $0.id == selectable.id }) {
                            Image(systemName: "checkmark").foregroundColor(.accentColor)
                        }
                    }
                }.tag(selectable.id)
            }
        }.listStyle(GroupedListStyle())
    }

    private func toggleSelection(selectable: Selectable) {
        if let existingIndex = selected.firstIndex(where: { $0.id == selectable.id }) {
            selected.remove(at: existingIndex)
        } else {
            selected.append(selectable)
        }
    }
}

struct MultiSelectionView_Previews: PreviewProvider {
    @State
    static var selected: [Weekday] = Weekday.allCases
    
    static var previews: some View {
        NavigationView {
            MultiSelectionView(
                options: Weekday.allCases,
                selected: $selected
            )
        }
    }
}
