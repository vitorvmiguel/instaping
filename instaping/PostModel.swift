//
//  PostModel.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 22/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

class PostModel {
    
    var id: String?
    var createdBy: String?
    var image: String?
    var storageUUID: String?
    var subtitle: String?
    var timestamp: String?
    var userUid: String?
    
    init(id: String?, createdBy: String?, image: String?, storageUUID: String?, subtitle: String?, timestamp: String?, userUid: String?) {
        self.id = id;
        self.createdBy = createdBy;
        self.image = image;
        self.storageUUID = storageUUID;
        self.subtitle = subtitle;
        self.timestamp = timestamp;
        self.userUid = userUid;
    }
}
