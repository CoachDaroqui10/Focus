//
//  Post.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 04/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Post
{
    var user : String
    var username : String
    var timestamp : NSNumber
    var text : String
    var image : String
    
    var dictionary: [String : Any] {
        return ["user": user,"username": username, "timestamp": NSDate().timeIntervalSince1970, "text" : text, "image" : image]
    }
    
    init?(dictionary: [String : Any])
    {
        user = dictionary["user"] as! String
        username = dictionary["username"] as! String
        timestamp = dictionary["timestamp"] as! NSNumber
        text = dictionary["text"] as! String
        image = dictionary["image"] as! String
    }
}
