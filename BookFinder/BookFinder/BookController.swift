//
//  BookController.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/27/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class BookController: UIViewController, UITableViewDelegate,  UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var theBooks: [Book2] = BookManager.sharedInstance.searchData
    var myindex = 0

    @IBOutlet weak var searchbar2: UISearchBar!
    var searching = false
    override func viewDidLoad() {
        theBooks = BookManager.sharedInstance.searchData
        print(theBooks)
        tableView.dataSource = self
        tableView.delegate = self
        self.searchbar2.delegate = self
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        theBooks = BookManager.sharedInstance.searchData
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theBooks = BookManager.sharedInstance.searchData
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return BookManager.sharedInstance.searchData.count
        } else {
            return theBooks.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theBookCell", for: indexPath) as! SearchCell
        if (searching) {
            let book = BookManager.sharedInstance.searchData[indexPath.row]

            cell.setBook(book: book)

        } else {
            let book = theBooks[indexPath.row]

            cell.setBook(book: book)

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myindex = indexPath.row
        let vc = storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController
        vc?.bookID = BookManager.sharedInstance.searchData[myindex].id
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        theBooks = BookManager.sharedInstance.searchData
        searching = true
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = self.searchbar2.text {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            try? BookManager.sharedInstance.search(withText: searchText, { () in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.searchbar2.resignFirstResponder()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchbar2.text = ""
        tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

