//
//  ActivityListMoveView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/06.
//

import SwiftUI
import CoreData

struct ActivityListMoveView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.priority, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Activity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \Activity.identifier) { item in
                    Text(item.title ?? "No title")
                }.onMove(perform: moveItems)
            }.toolbar {
                ToolbarItem {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }.environment(\.editMode, .constant(.active))
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        do {
            for i in source {
                switch destination {
                case 0:
                    items[i].priority = items[destination].priority + 1
                case items.count:
                    items[i].priority = items[destination - 1].priority - 1
                default:
                    items[i].priority = (items[destination - 1].priority + items[destination].priority) / 2.0
                }
            }
            try viewContext.save()
        } catch {
            print("[UI][Error] \(error)")
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    ActivityListMoveView()
        .environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
}
