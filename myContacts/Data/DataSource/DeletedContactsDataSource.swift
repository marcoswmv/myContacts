//
//  DeletedContactsDataSource.swift
//  myContacts
//
//  Created by Marcos Vicente on 30.08.2020.
//  Copyright © 2020 Antares Software Group. All rights reserved.
//

import UIKit
import RealmSwift

class DeletedContactsDataSource: BaseDataSource {
    
    private(set) var data: Results<Contact>?
    private var filteredData: Results<Contact>?
    private var isSearching: Bool = false
    
    var deleteSelectedContacts: ((_ indexPaths: [IndexPath]) -> Void)?
    var recoverSelectedContacts: ((_ indexPaths: [IndexPath]) -> Void)?
    
    override func setup() {
        super.setup()
        
        self.deleteSelectedContacts = { [weak self] indexPaths in
            guard let self = self else { return }
            var contactsToDelete = [Contact]()
            for indexPathToDelete in indexPaths {
                contactsToDelete.append(self.data![indexPathToDelete.row])
            }
            Alert.showActionSheetToAskForConfirmationToDelete(on: UIApplication.topViewController()!) { [weak self] (delete) in
                guard let self = self else { return }
                DataBaseManager.shared.delete(contacts: contactsToDelete)
                self.tableView.reloadData()
            }
        }
        
        self.recoverSelectedContacts = { [weak self] indexPaths in
            
            guard let self = self else { return }
            var contactsRecover = [Contact]()
            for indexPathToRecover in indexPaths {
                contactsRecover.append(self.data![indexPathToRecover.row])
            }
            _ = contactsRecover.map({ ContactStoreManager.shared.addContact($0) })
            DataBaseManager.shared.delete(contacts: contactsRecover)
            self.tableView.reloadData()
        }
    }
    
    override func reload() {
//        onLoading!(true)
        let sharedDatabase = DataBaseManager.shared
        let result = sharedDatabase.getContacts(wasDeleted: true)
        
//        TO-DO: VERIFICATION of work correctness
        result.forEach { sharedDatabase.updateDaysUntilDeletion(for: $0) }
        data = result
        tableView.reloadData()
    }
    
    func startQuery(with text: String) {
        isSearching = !text.isEmpty ? true : false
        let queryResult = DataBaseManager.shared.filterContacts(from: text, wasDeleted: true)
        filteredData = queryResult
        tableView.reloadData()
    }
    
//    MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            Alert.showActionSheetToAskForConfirmationToDelete(on: UIApplication.topViewController()!) { [weak self] delete in
                guard let self = self else { return }
                let contactToDelete = [self.data![indexPath.row]]
                DataBaseManager.shared.delete(contacts: contactToDelete)
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recoverAction = UIContextualAction(style: .normal, title: "Recover") { [weak self] (action, view, completionHandler) in
            
            guard let self = self else { return }
            let contactToRecover = self.data![indexPath.row]
            ContactStoreManager.shared.addContact(contactToRecover)
            DataBaseManager.shared.delete(contacts: [contactToRecover])
            self.tableView.reloadData()
            completionHandler(true)
        }
        recoverAction.backgroundColor = .link
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        To set back the table view background to it's default style
        tableView.backgroundView = UIView()
        tableView.separatorStyle = .singleLine
        
        if isSearching {
            if filteredData?.count == 0 {
                addTableViewBackgroundView(with: "No Results")
                return 0
            }
            return filteredData?.count ?? 0
        } else {
            return data?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedContactCell", for: indexPath) as! DeletedContactCell
        
        if isSearching {
            cell.data = filteredData![indexPath.row]
        } else {
            cell.data = data![indexPath.row]
        }
        
        return cell
    }
}
