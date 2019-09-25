//
//  Group.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 26/08/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation

struct Group
{
    var name : String
    var imageURL : String
    var dictionary: [String : Any] {
        return ["name": name, "imageURL": imageURL]
    }
    
    init?(dictionary: [String : Any])
    {
        name = dictionary["name"] as! String
        imageURL = dictionary["imageURL"] as! String
    }
}
