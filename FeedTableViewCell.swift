//
//  FeedTableViewCell.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 29/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postAuthor: UILabel!
    @IBOutlet weak var postSubtitle: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
