//
//  GroupUserProfileViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 19/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class GroupUserProfileViewController: UIViewController
{
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    
    var user = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DatabaseService.sharedInstance.recieveAnotherUserData(user: user, onComplete: onComplete(user:))
    }
    
    func onComplete(user: User?) -> Void
    {
        if let userRetrieved = user
        {
            self.user = userRetrieved
            print("Usuario obtenido correctamente")
            DatabaseService.sharedInstance.downloadUserImage(user: self.user, onComplete: onCompletePic(image:))
            print(self.user)
            setupView(user: self.user)
        }
        else
        {
            print("Error: No hay user")
        }
    }
    
    func onCompletePic(image: UIImage?) -> Void
    {
        if let image = image
        {
            print("Imagen obtenida correctamente")
            imageViewProfilePic.image = image
        }
        else
        {
            print("Error obteniendo la imagen del usuario")
        }
    }
    
    func setupView(user: User)
    {
        labelName.text = user.name + " " + user.lastName
        labelDescription.text = user.description
    }
}
