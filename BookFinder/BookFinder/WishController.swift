//
//  WishController.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class WishController: UIViewController {
    
    var favBooks: [Book]?

    override func viewDidLoad() {
        favBooks = BookManager.sharedInstance.initialBooks
        super.viewDidLoad()
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

extension WishController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let nflTeams = favBooks else {

            return 0
        }
        return nflTeams.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! WishCell
        if let nflTeams = favBooks {
            
            let book = nflTeams[indexPath.row]

            cell.setWish(book: book)

        }
        return cell
    }
}
