//
//  DataController.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//


import Foundation
import CoreData
import MapKit

class DataController {
    let persistentContainer: NSPersistentContainer
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContext(){
        viewContext.automaticallyMergesChangesFromParent = true
        
        
    }
    
    func load(completion: (()-> Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescripton, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContext()
        }
    }
    
}


// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
//        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
            print("autosave: view has chages which has been saved")
        } else {
            print("autosave: there was no changes")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
