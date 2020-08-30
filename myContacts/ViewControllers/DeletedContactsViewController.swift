//
//  DeletedContactsViewController.swift
//  myContacts
//
//  Created by Marcos Vicente on 30.08.2020.
//  Copyright © 2020 Antares Software Group. All rights reserved.
//

import UIKit

class DeletedContactsViewController: UIViewController {
    
//    MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func manageOnTouchUpInside(_ sender: Any) {
    }
    
    
//    MARK: - PROPERTIES
    
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private let myRefreshControl: UIRefreshControl = UIRefreshControl()
    private var isManaging: Bool = false
    
    var dataSource: DeletedContactsDataSource?
    var shouldBeginEditing: Bool = true
    var timer: Timer?
    
    
//    MARK: - LIFECYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        setupNavigationBar()
        setupToolbar()
        tableView.isEditing = false
    }
    

//    MARK: - SETUP AND CONFIGURATION
    
    fileprivate func setupDataSource() {
        dataSource = DeletedContactsDataSource(tableView: tableView)
        dataSource?.onLoading = { (isLoading) in
//            TO-DO: Implement loading animation
//            self.displayLoading(loading: isLoading)
        }
        dataSource?.onError = { (error) in
            Alert.showErrorAlert(on: self, message: error.localizedDescription)
        }
        dataSource?.reload()
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Deleted"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        
        setupSearchController()
        setupRefreshControl()
    }
    
    fileprivate func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    fileprivate func setupRefreshControl() {
        tableView.refreshControl = myRefreshControl
        myRefreshControl.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
    }
    
    fileprivate func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let selectButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(handleSelect))
        
        if !(toolbarItems?.isEmpty ?? true) {
            toolbarItems?.removeAll()
        }

        toolbarItems = [flexibleSpace, selectButton]
    }
    
    fileprivate func setupToolbarForDeletion() {
        if !toolbarItems!.isEmpty {
            toolbarItems?.removeAll()
        }
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(handleDelete))

        toolbarItems = [cancelButton, flexibleSpace, deleteButton]
    }
    
    fileprivate func updateUIAfterDeletingSelectedContacts() {
        navigationController?.setToolbarHidden(true, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
        tableView.setEditing(false, animated: true)
        tableView.isEditing = false
    }

//    MARK: - HANDLERS
    
    @objc private func handleRefresh() {
        let delay = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            self.dataSource?.reload()
            self.myRefreshControl.endRefreshing()
        }
    }
    
    @objc private func handleManage() {
        if isManaging {
            isManaging = false
            navigationController?.setToolbarHidden(true, animated: true)
        } else {
            isManaging = true
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    @objc private func handleSelect() {
        setupToolbarForDeletion()
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        if tableView.isEditing {
            tableView.setEditing(tableView.isEditing, animated: true)
            tableView.isEditing = false
        } else {
            tableView.setEditing(tableView.isEditing, animated: true)
            tableView.isEditing = true
        }
    }
    
    @objc private func handleCancel() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
        tableView.setEditing(false, animated: true)
        tableView.isEditing = false
        setupToolbar()
    }
    
    @objc private func handleDelete() {
//        TO-DO: First Ask the user if he's sure of this irrevesible action
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths.reversed() {
//                dataSource?.deleteSelectedContacts!(indexPath)
            }
            updateUIAfterDeletingSelectedContacts()
            setupToolbar()
        }
    }
}