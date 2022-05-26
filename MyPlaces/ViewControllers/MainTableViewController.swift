//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Maksim  on 21.05.2022.
//

import UIKit
import RealmSwift

class MainTableViewController: UITableViewController {
    
    // MARK: - Private property
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    
    private var ascendingSorting = true
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - IBOutlet
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    // MARK: - Private method class
    override func viewDidLoad() {
        super.viewDidLoad()
        places = StorageManager.shared.realm.objects(Place.self)
        setupSearchController()
    }
    //?
    private func sortingByDateOfName() {
        if segmentControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
    
    private func sortingReversed() {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
            places = places.sorted(byKeyPath: "date")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
            places = places.sorted(byKeyPath: "name")
        }
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredPlaces.count : places?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let content = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        cell.contentView.backgroundColor = .white
        cell.configure(with: content)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Table view delegate    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let newPlaceVC = segue.destination as? NewPlaceTableViewController else { return }
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        newPlaceVC.currentPlace = place
    }
    
    // MARK: - unwindSegue
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        newPlaceVC.savePlace()
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        sortingByDateOfName()
    }
    
    @IBAction func reversedSortingAction(_ sender: Any) {
        sortingReversed()
        sortingByDateOfName()
    }
    
    // MARK: - deinit class
    deinit {
        print("deinit", MainTableViewController.self)
    }
}

// MARK: - UISearchController
extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText,searchText)
        tableView.reloadData()
    }
}

