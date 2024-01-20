//
//  ContributionListView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/04.
//

import SwiftUI

struct ContributionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appDelegate: AppDelegate
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.priority, ascending: false)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Contribution.date, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Contribution>

    @State var activity: Activity?
    @State private var sections: [Date?] = []
    @State private var itemsBySection: [Date?: [Contribution]] = [:]
    @State private var editingItem: Contribution? = nil
    @State private var range: Range<Date>? = nil
    @State private var query: String = ""

    init(activity: Activity? = nil) {
        self.activity = activity
    }

    var body: some View {
        List {
            if items.isEmpty {
                if activities.isEmpty {
                    Text("Contribution.EmptyMessage")
                } else {
                    Text("Contribution.EmptyMessageWithActivity")
                }
            } else {
                ForEach(sections, id: \.self) { d in
                    Section(d?.asDateSectionString ?? "") {
                        ForEach(itemsBySection[d] ?? [], id: \Contribution.createdAt) { item in
                            DisclosureIndicatorRow() {
                                editingItem = item
                            } label: {
                                ContributionItemView(
                                    item: item,
                                    activity: findActivityByContribution(item)
                                )
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }.task {
            refresh()
        }.refreshable {
            refresh()
        }.sheet(item: $editingItem, onDismiss: {
            editingItem = nil
        }, content: {
            if let item = findActivityByContribution($0) {
                ContributionEditView(
                    activity: item,
                    activities: Array(activities),
                    action: .update($0)
                )
            } else {
                EmptyView()
            }
        }).searchable(
            text: $query,
            prompt: "Contribution.Search"
        ).onChange(of: query) {
            refresh()
        }.toolbar {
            ToolbarItem {
                Menu(content: {
                    Button {
                        activity = nil
                    } label: {
                        if activity?.identifier == nil {
                            Image(systemName: "checkmark")
                        }
                        Text("Contribution.NoFilter")
                    }
                    ForEach(activities, id:\Activity.identifier) { item in
                        Button {
                            activity = item
                        } label: {
                            if item.identifier == activity?.identifier {
                                Image(systemName: "checkmark")
                            }
                            Text(item.title ?? "No title")
                        }
                    }
                }, label: {
                    if activity == nil {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                })
            }
        }.navigationTitle("Contribution")
    }

    private func findActivityByContribution(_ contribution: Contribution) -> Activity? {
        return activities.first { $0.id == contribution.activityId } ?? activity
    }

    private func refresh() {
        var predicates: [NSPredicate] = []
        if let activityId = activity?.id {
            predicates.append(NSPredicate(format: "activityId = %@", activityId as CVarArg))
        }
        if !query.isEmpty {
            predicates.append(NSPredicate(format: "note contains %@", query))
        }
        self.items.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        sections = items.compactMap { $0.sectionKey }.unique
        itemsBySection = Dictionary(grouping: items, by: { $0.sectionKey })
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.compactMap {
                itemsBySection[sections.first!]?[$0]
            }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                refresh()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContributionListView(activity: Activity.preview(context: PersistentContainer.shared.viewContext))
}
