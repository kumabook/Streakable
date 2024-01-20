//
//  PersistentContainer.swift
//  Reminder
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import Foundation
import CoreData

public class PersistentContainer: NSPersistentCloudKitContainer {
    static var shared: PersistentContainer = {
        let container = PersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    func saveContext(_ conext: NSManagedObjectContext? = nil) throws {
        let ctx = conext ?? viewContext
        guard ctx.hasChanges else {
            return
        }
        try ctx.save()
    }

    func fetchEntities<Entity: NSManagedObject>(predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) throws -> [Entity] {
        let ctx = context ?? viewContext
        guard let entityName = Entity.entity().name else { return [] }
        let request = NSFetchRequest<Entity>(entityName: entityName)
        request.predicate = predicate
        return try ctx.fetch(request)
    }

    func findEntity<Entity: NSManagedObject>(byId id: UUID, context: NSManagedObjectContext? = nil) throws -> Entity? {
        let predicate = NSPredicate(format: "id = %@", id as CVarArg)
        let entities: [Entity] = try fetchEntities(predicate: predicate, context: context)
        return entities.first
    }

    func findEntity<Entity: NSManagedObject>(byName name: String, context: NSManagedObjectContext? = nil) throws -> Entity? {
        let predicate = NSPredicate(format: "name = %@", name)
        return try fetchEntities(predicate: predicate, context: context).first
    }

    @discardableResult
    func insertEntity<Entity: NSManagedObject>(entity: Entity, context: NSManagedObjectContext? = nil) throws -> Entity {
        let ctx = context ?? viewContext
        ctx.insert(entity)
        try ctx.save()
        return entity
    }

    func deleteEntity<Entity: NSManagedObject>(entity: Entity, context: NSManagedObjectContext? = nil) throws {
        let ctx = context ?? viewContext
        ctx.delete(entity)
        try ctx.save()
    }
}
