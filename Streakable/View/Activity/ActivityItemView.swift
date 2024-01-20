//
//  ActivityItemView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import SwiftUI

struct ActivityItemView: View {
    var item: Activity
    var streak: Streak

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title ?? "No title")
                .font(.title)
                .bold()
                .foregroundColor(.primary)
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "alarm").font(.callout)
                        if let date = item.remindsAt?.asActivityDateString {
                            Text(date)
                                .font(.body)
                                .lineLimit(1)
                        }
                        if let s = item.reccurenceText {
                            Text(s)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                                .cornerRadius(12)
                                .lineLimit(1)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor)
                                )
                        }
                    }
                    if let note = item.note {
                        Text(note).font(.caption).lineLimit(3)
                    }
                    HStack {
                        Spacer()
                    }
                }
                VStack(alignment: .trailing) {
                    HStack {
                        Text(LocalizedStringKey("Contributions"))
                        Text("\(streak.contribution)")
                    }
                    HStack {
                        Text(LocalizedStringKey("Scores"))
                        Text("\(streak.score)")
                    }
                    HStack {
                        Text(LocalizedStringKey("CurrentStreak"))
                        Text("\(streak.current)")
                    }
                    HStack {
                        Text("LongestStreak")
                        Text("\(streak.longest)")
                    }
                }.font(.caption)
            }
        }
    }
}

struct ActivityItemView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityItemView(
            item: Activity(context: PersistentContainer.shared.viewContext),
            streak: Streak()
        )
    }
}
