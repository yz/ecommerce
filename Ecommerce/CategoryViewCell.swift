//
//  CategoryViewCell.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 3/6/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit

class CategoryViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var categoryNameLabel: UILabel!

    var image: UIImage!
    
    var descr: String!
    
    var objID: String!
    
}
