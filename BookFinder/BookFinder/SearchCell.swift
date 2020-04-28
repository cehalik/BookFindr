//
//  SearchCell.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/26/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!

    func setBook (book: Book2) {
        bookTitle.text = book.title
    }

}
