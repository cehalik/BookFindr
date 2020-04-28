//
//  Book.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import Foundation
import UIKit

struct Book {
    var title: String
    var image: UIImage
    var author: String
    var description: String
    var wishList: Bool
    
    init?(title: String, image: UIImage, auth: String, desc: String, wish: Bool = false){
        self.title = title
        self.image = image
        self.author = auth
        self.description = desc
        self.wishList = wish
    }
    
}
