//
//  Sort.swift
//  ExpenseTracker
//
//  Created by Simphiwe Mbokazi on 15/07/23.
//  

//

import Foundation

// Enum that defines the types of sorting available
enum SortType: String, CaseIterable {
    case date   // Sorting by date
    case amount // Sorting by amount
}

// Enum that defines the order of sorting
enum SortOrder: String, CaseIterable {
    case ascending  // Ascending order
    case descending // Descending order
}

// Extension that makes SortType Identifiable for use with SwiftUI
extension SortType: Identifiable {
    var id: String { rawValue } // The rawValue is used as the id
}

// Extension that makes SortOrder Identifiable for use with SwiftUI
extension SortOrder: Identifiable {
    var id: String { rawValue } // The rawValue is used as the id
}

// Struct that holds the sort type and sort order
struct ExpenseLogSort {
    var sortType: SortType
    var sortOrder: SortOrder

    // A computed property that returns true if the sortOrder is ascending
    var isAscending: Bool {
        sortOrder == .ascending ? true : false
    }
    
    // A computed property that returns an NSSortDescriptor based on the sortType and sortOrder
    // This can be used directly with an NSFetchRequest to sort the results of a fetch request
    var sortDescriptor: NSSortDescriptor {
        switch sortType {
        case .date:
            // If sorting by date, return a sort descriptor that sorts by the date field
            return NSSortDescriptor(keyPath: \ExpenseLog.date, ascending: isAscending)
        case .amount:
            // If sorting by amount, return a sort descriptor that sorts by the amount field
            return NSSortDescriptor(keyPath: \ExpenseLog.amount, ascending: isAscending)
        }
    }
}
