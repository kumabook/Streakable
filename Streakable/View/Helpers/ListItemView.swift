//
//  ListItemView.swift
//  Reminder
//
//  Created by Hiroki Kumamoto on 2023/01/03.
//

import SwiftUI


struct ListItemView: View {
    var title: LocalizedStringKey
    var detail: String? = nil
    var detailColor: Color? = nil
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text(title)
                .font(.body)
                .lineLimit(1)
            Spacer()
            Text(detail ?? "")
                .font(.body)
                .foregroundColor(detailColor)
        }
        .padding(.vertical, 4)
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(title: "タイトル", detail: "詳細")
    }
}
