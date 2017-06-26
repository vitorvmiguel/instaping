//
//  UserModel.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 26/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

class UserModel {
    
    var id: String?
    var profileImage: String?
    var followsArray = [String]()
    var numberOfFollowers: String?
    var followedByArray = [String]()
    var numberOfFollowedBy: String?
    
    init(id: String?, profileImage: String?, followsArray: [String], numberOfFollowers: String?, followedByArray: [String], numberOfFollowedBy: String?) {
        self.id = id;
        self.profileImage = profileImage;
        self.followsArray = followsArray;
        self.numberOfFollowers = numberOfFollowers;
        self.followedByArray = followedByArray;
        self.numberOfFollowedBy = numberOfFollowedBy;
    }
}
