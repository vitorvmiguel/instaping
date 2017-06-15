//
//  FeedTableViewCell.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 29/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

protocol FeedTableViewCellDelegate: class {
    func feedCellFollowButtonPressed(sender: FeedTableViewCell)
}

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postAuthor: UILabel!
    @IBOutlet weak var postSubtitle: UITextView!
    weak var delegate: FeedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.feedCellFollowButtonPressed(sender: self)
        }
        
    }

}
