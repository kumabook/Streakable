//
//  ActivityListView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2022/12/31.
//

import SwiftUI
import CoreData

struct ActivityListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(\.editMode) var editMode

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.priority, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Activity>
    
    @State var streaks: [UUID?:Streak] = [:]
    @State var calendars: [UUID?:ContribCalendar] = [:]
    @State var calendar: ContribCalendar?
    @State private var creating: Bool = false
    @State private var editingItem: Activity? = nil
    @State private var moving: Bool = false

    var body: some View {
        List {
            if items.isEmpty {
                Button {
                    creating = true
                } label: {
                    Text("Activity.EmptyMessage")
                }
            }
            if let value = calendar {
                Section() {
                    VStack(alignment: .leading) {
                        Text("All")
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                        ContributionCalendarView(value: value)
                    }.padding([.top], 8)
                }
            }
            Section {
                ForEach(items, id: \Activity.identifier) { item in
                    NavigationLink {
                        ActivityDetailView(
                            activity: item,
                            streak: streaks[item.id] ?? Streak(),
                            calendar: calendars[item.id] ?? ContribCalendar(date: Date())
                        )
                    } label: {
                        ActivityItemView(
                            item: item,
                            streak: streaks[item.id] ?? Streak()
                        )
                    }
                    ContributionCalendarView(value: calendars[item.id] ?? ContribCalendar(date: Date()))
                }
            }
        }.task {
            await refresh()
        }.refreshable {
            await refresh()
        }
        .toolbar {
            ToolbarItem {
                Menu(content: {
                    Button(action: { creating = true }) {
                        Label("New", systemImage: "plus")
                    }
                    Button(action: { moving = true }) {
                        Label("Move", systemImage: "arrow.up.and.line.horizontal.and.arrow.down")
                    }
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
            }
        }.sheet(isPresented: $creating, content: {
            ActivityEditView(priority: Double(items.count))
        }).sheet(item: $editingItem, content: {
            ActivityEditView(activity: $0)
        }).sheet(isPresented: $moving, content: {
            ActivityListMoveView()
        }).navigationTitle("Activity")
    }

    func refresh() async {
        do {
            let (streaks, calendars, calendar) = try Contribution.retrieve(Array(items), context: viewContext)
            self.streaks = streaks
            self.calendars = calendars
            self.calendar = calendar
        } catch {
            print("[UI][Error] \(error)")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
            .environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
    }
}
