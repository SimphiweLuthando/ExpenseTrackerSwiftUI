//
//  CoreDataStack.swift
//  ExpenseTracker
//
//  Created by Simphiwe Mbokazi on 2023/07/15.
//
//

import Foundation
import CoreData

// This class is responsible for setting up and managing the Core Data stack, including the persistent container
class CoreDataStack {
    
    // The name of the container, usually it matches with the name of your xcdatamodeld file
    private let containerName: String
    
    // The NSManagedObjectContext associated with the main queue. (Used for reading and writing from/to the database)
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    
    // The persistent container setup, which contains the Core Data stack and is responsible for loading and saving data
    private lazy var persistentContainer: NSPersistentContainer = {
        // Initialize a container with the name provided
        let container = NSPersistentContainer(name: containerName)
        
        // Load the persistent stores
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Handle the case if an error occurred during the loading of a persistent store
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
            // Print the description of the store loaded
            print(storeDescription)
        })
        return container
    }()
    
    // Initialize a new CoreDataStack with the name of the persistent container
    init(containerName: String) {
        self.containerName = containerName
        _ = persistentContainer
    }
}

// Extension to NSManagedObjectContext to add a saveContext helper method
extension NSManagedObjectContext {
    
    // This method saves the context if there are any changes to save. Throws an error if the save fails
    func saveContext() throws {
        // Check if the context has changes before attempting to save it
        guard hasChanges else { return }
        // Try to save the context and throw an error if it fails
        try save()
    }
}

