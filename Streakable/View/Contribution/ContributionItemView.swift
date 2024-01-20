//
//  ContributionItemView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/04.
//

import SwiftUI

struct ContributionItemView: View {
    @ObservedObject var item: Contribution
    var activity: Activity?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                if let activityTitle = activity?.title {
                    Text(activityTitle)
                        .bold()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                Text(item.date?.asContributionTimeString ?? "Unknown time")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(1)
                if let s = item.note, !s.isEmpty {
                    Text(s)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContributionItemView(
        item: Contribution(context: PersistentContainer.shared.viewContext),
        activity: Activity(context: PersistentContainer.shared.viewContext)
    )
}
