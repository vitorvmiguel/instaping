//
//  ImageCollectionViewCell.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 19/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var DiscoverImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.DiscoverImageView.image = nil
    }
    
}