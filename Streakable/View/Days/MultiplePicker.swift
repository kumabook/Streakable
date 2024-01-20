//
//  MultiplePicker.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/06/08.
//

import SwiftUI

protocol MultiSelectable: Identifiable & Hashable {
    var title: String { get }
    var shortTitle: String { get }
}

struct MultiSelector<LabelView: View, Selectable: MultiSelectable>: View {
    let label: LabelView
    let options: [Selectable]
    var selected: Binding<[Selectable]>

    private var formattedSelectedListString: String {
        ListFormatter.localizedString(
            byJoining: options.filter { d in selected.contains(where: { $0.id == d.id }) }.map { $0.shortTitle }
        )
    }

    var body: some View {
        NavigationLink(destination: multiSelectionView()) {
            HStack {
                label
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func multiSelectionView() -> some View {
        MultiSelectionView(options: options, selected: selected)
    }
}

struct MultiSelector_Previews: PreviewProvider {
    @State
    static var selected: [Weekday] = Weekday.allCases
    
    static var previews: some View {
        NavigationView {
            Form {
                MultiSelector<Text, Weekday>(
                    label: Text("Multiselect"),
                    options: Weekday.allCases,
                    selected: $selected
                )
            }.navigationTitle("Title")
        }
    }
}
