//
//  ContentView.swift
//  Reminder
//
//  Created by Hiroki Kumamoto on 2022/12/30.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.priority, ascending: false)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    @State private var selection = 1

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                ActivityListView()
            }.tabItem {
                Text("Activity")
                Image(systemName: "square.grid.3x3.topleft.filled")
            }.tag(0)
            NavigationView {
                ReminderListView()
            }.tabItem {
                Text("Reminder")
                Image(systemName: "alarm")
            }.tag(1)
            NavigationView {
                ContributionListView()
            }.tabItem {
                Text("ContributionList")
                Image(systemName: "timer")
            }.tag(2)
        }.task {
            if activities.isEmpty {
                selection = 0
            } else {
                selection = 1
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
    }
}
