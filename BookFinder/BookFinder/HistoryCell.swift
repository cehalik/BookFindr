//
//  HistoryCell.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var historyTitleLabel: UILabel!
    @IBOutlet weak var historyImageView: UIImageView!
    
    func setHistory (book: Book){
        historyTitleLabel.text = book.title
        historyImageView.image = book.image
    }

}
