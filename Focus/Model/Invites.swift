//
//  Invites.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 05/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation

struct Invite
{
    var user : String
    var timestamp : NSNumber
    
    var dictionary: [String : Any] {
        return ["user": user, "timestamp": NSDate().timeIntervalSince1970]
    }
    
    init?(dictionary: [String : Any])
    {
        user = dictionary["user"] as! String
        timestamp = dictionary["timestamp"] as! NSNumber
    }
}
