//
//  Invite.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 05/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation

struct Invite
{
    var username : String
    var group : String
    var timestamp : NSNumber
    
    var dictionary: [String : Any] {
        return ["username": username, "group": group, "timestamp": NSDate().timeIntervalSince1970]
    }
    
    init?(dictionary: [String : Any])
    {
        username = dictionary["username"] as! String
        group = dictionary["group"] as! String
        timestamp = dictionary["timestamp"] as! NSNumber
    }
}
