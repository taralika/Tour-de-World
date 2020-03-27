//
//  DataController.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import CoreData

class DataController
{
    lazy var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "TourDeWorld")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError?
            {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static let shared = DataController(modelName: "TourDeWorld")
    
    var viewContext: NSManagedObjectContext
    {
        return persistentContainer.viewContext
    }
    
    init(modelName: String)
    {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil)
    {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else
            {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func saveContext ()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
