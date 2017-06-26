//
//  FeedTableViewCell.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 29/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postAuthor: UILabel!
    @IBOutlet weak var postSubtitle: UILabel!
    @IBOutlet weak var likesCounter: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var tapAction: ((FeedTableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        self.profilePicture.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        tapAction?(self)
    }

}
