//
//  User.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 19/08/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation

struct User
{
    var name : String
    var lastName : String
    var username : String
    var description : String
    var imageUrl : String
    
    var dictionary: [String : Any] {
        return ["name": name, "lastName": lastName, "username" : username, "description" : description, "imageUrl" : imageUrl]
    }
    
    init?(dictionary: [String : Any])
    {
        name = dictionary["name"] as! String
        lastName = dictionary["lastName"] as! String
        username = dictionary["username"] as! String
        description = dictionary["description"] as! String
        imageUrl = dictionary["imageUrl"] as! String
    }
}
