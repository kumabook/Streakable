//
//  DisclosureIndicatorRow.swift
//  Reminder
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import SwiftUI

struct DisclosureIndicatorRow<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action, label: {
            HStack {
                label().layoutPriority(1)
                NavigationLink(destination: EmptyView(), label: { EmptyView() })
            }.foregroundColor(.primary)
        })
    }
}

struct DisclosureIndicatorRow_Previews: PreviewProvider {
    static var previews: some View {
        DisclosureIndicatorRow(action: {}, label: { EmptyView() })
    }
}
