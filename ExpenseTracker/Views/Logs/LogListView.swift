//
//  LogListView.swift
//  ExpenseTracker
//
//  Created by Simphiwe Mbokazi on 15/07/23.
//  

//

import SwiftUI
import CoreData

struct LogListView: View {
    
    // 1
    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext
    
    // 2
    @FetchRequest(
        entity: ExpenseLog.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ExpenseLog.date, ascending: false)
        ]
    )
    private var result: FetchedResults<ExpenseLog>
    @State var logToEdit: ExpenseLog?
    
    // 3
    init(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor) {
        let fetchRequest = NSFetchRequest<ExpenseLog>(entityName: ExpenseLog.entity().name ?? "ExpenseLog")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        _result = FetchRequest(fetchRequest: fetchRequest)
    }
    
    // 4
    var body: some View {
        List {
            ForEach(result) { (log: ExpenseLog) in
                Button(action: {
                    self.logToEdit = log
                }) {
                    HStack(spacing: 16) {
                        CategoryImageView(category: log.categoryEnum)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(log.nameText).font(.headline)
                            Text(log.dateText).font(.subheadline)
                        }
                        Spacer()
                        Text(log.amountText).font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: onDelete)
            .sheet(item: $logToEdit, onDismiss: {
                self.logToEdit = nil
            }) { (log: ExpenseLog) in
                LogFormView(
                    name: log.name ?? "",
                    amount: log.amount?.doubleValue ?? 0,
                    category: Category(rawValue: log.category ?? "") ?? .food,
                    date: log.date ?? Date(),
                    logToEdit: log,
                    context: self.context
                )
            }
        }
    }
    
    private func onDelete(with indexSet: IndexSet) {
        indexSet.forEach { index in
            let log = result[index]
            context.delete(log)
        }
        try? context.saveContext()
    }
}

struct LogListView_Previews: PreviewProvider {
    static var previews: some View {
        let stack = CoreDataStack(containerName: "ExpenseTracker")
        let sortDescriptor = ExpenseLogSort(sortType: .date, sortOrder: .descending).sortDescriptor
        return LogListView(predicate: nil, sortDescriptor: sortDescriptor)
            .environment(\.managedObjectContext, stack.viewContext)
    }
}

