//
//  SearchController.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/26/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class SearchController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var bookCell: [Book2]?
    
    override func viewDidLoad() {
        bookCell = BookManager.sharedInstance.searchData
        print("test")
        self.searchBar.delegate = self
        super.viewDidLoad()
    }
    
    
    @IBAction func refreshData(_ sender: Any) {
        bookCell = BookManager.sharedInstance.searchData
        self.tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let nflTeams = bookCell else {

            return 0
        }
        return nflTeams.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Hello")
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        if let nflTeams = bookCell {
            
            let book = nflTeams[indexPath.row]
            print(book.title)

            cell.textLabel!.text = book.title
            cell.detailTextLabel!.text = book.author

        }
        
        return cell
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = self.searchBar.text {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            try? BookManager.sharedInstance.search(withText: searchText, { () in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.searchBar.resignFirstResponder()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
    }

}
