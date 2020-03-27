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
    let persistentContainer: NSPersistentContainer
    
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
}
