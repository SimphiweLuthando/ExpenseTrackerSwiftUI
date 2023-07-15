//
//  ExpenseLog+Extension.swift
//  ExpenseTracker
//
//  Created by Simphiwe Mbokazi on 2023/07/15.
//  Copyright © 2023 Keke & Simphiwe. All rights reserved.
//

import Foundation
import CoreData

// This extension provides convenience accessors and methods for the ExpenseLog entity
extension ExpenseLog {
    
    // Converts the category from a String to the Category enum
    var categoryEnum: Category {
        Category(rawValue: category ?? "") ?? .other
    }
    
    // Provides a default value for the name field if it is nil
    var nameText: String {
        name ?? ""
    }
    
    // Converts the date to a String using the application's date formatter
    var dateText: String {
        Utils.dateFormatter.localizedString(for: date ?? Date(), relativeTo: Date())
    }
    
    // Converts the amount to a String using the application's number formatter
    var amountText: String {
        Utils.numberFormatter.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
    }
    
    // Builds a predicate based on the provided category filters and search text
    static func predicate(with categories: [Category], searchText: String) -> NSPredicate? {
        var predicates = [NSPredicate]()
        
        // If categories are selected, add them to the predicate
        if !categories.isEmpty {
            let categoriesString = categories.map { $0.rawValue }
            predicates.append(NSPredicate(format: "category IN %@", categoriesString))
        }
        
        // If there is search text, add it to the predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText.lowercased()))
        }
        
        // If no predicates were added, return nil
        if predicates.isEmpty {
            return nil
        } else {
            // Otherwise, return a compound predicate that combines all the predicates
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
    
    // Fetches the sum of the amounts for all expenses in each category and returns them in a completion handler
    static func fetchAllCategoriesTotalAmountSum(context: NSManagedObjectContext, completion: @escaping ([(sum: Double, category: Category)]) -> ()) {
    
        // Create an NSExpression to sum the amounts
        let keypathAmount = NSExpression(forKeyPath: \ExpenseLog.amount)
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathAmount])
        
        // Create an NSExpressionDescription to hold the sum
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .decimalAttributeType
        
        // Create a fetch request to get the sums by category
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ExpenseLog.entity().name ?? "ExpenseLog")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["category"]
        request.propertiesToFetch = [sumDesc, "category"]
        request.resultType = .dictionaryResultType
        
        // Execute the fetch request on the context
        context.perform {
            do {
                let results = try request.execute()
                
                // Process the results and convert them to a tuple of (Double, Category)
                let data = results.map { (result) -> (Double, Category)? in
                    guard
                        let resultDict = result as? [String: Any],
                        let amount = resultDict["sum"] as? Double, amount > 0,
                        let categoryKey = resultDict["category"] as? String,
                        let category = Category(rawValue: categoryKey) else {
                            return nil
                    }
                    return (amount, category)
                }.compactMap { $0 }
                
                // Call the completion handler with the result
                completion(data)
            } catch let error as NSError {
                // If an error occurred, print it and call the completion handler with an empty array
                print((error.localizedDescription))
                completion([])
            }
        }
    }
}
