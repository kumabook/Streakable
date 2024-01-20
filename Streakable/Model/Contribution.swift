//
//  Commit.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/03.
//

import Foundation
import CoreData

extension Contribution {
    var sectionKey: Date? {
        guard let d = date else { return nil }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: d)
        return Calendar.current.date(from: components)
    }

    static func retrieve(_ activities: [Activity], context: NSManagedObjectContext) throws -> ([UUID?: Streak], [UUID?: ContribCalendar], ContribCalendar) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Contribution.entity().name!)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Contribution.date, ascending: true)]
        request.propertiesToFetch = ["activityId", "date", "score"]
        request.resultType = .dictionaryResultType

        var streaks: [UUID?:Streak] = [:]
        var calendars: [UUID?:ContribCalendar] = [:]
        var calendar = ContribCalendar(date: Date())
        for activity in activities {
            streaks[activity.id] = Streak()
            calendars[activity.id] = ContribCalendar(date: Date())
        }

        for r in try context.fetch(request) {
            if
                let dic = r as? Dictionary<String, Any>,
                let id = dic["activityId"] as? UUID,
                let date = dic["date"] as? Date,
                let score = dic["score"] as? Int64,
                let activity = activities.first(where: { $0.id == id })
            {
                streaks[id]?.append(score, date, activity)
                calendars[id]?.append(score, date, activity)
                calendar.append(score, date, activity)
            }
        }
        return (streaks, calendars, calendar)
    }
}
