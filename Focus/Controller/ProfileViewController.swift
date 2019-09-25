//
//  ProfileViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 31/07/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController
{
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    
    var user = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        // Do any additional setup after loading the view.
        DatabaseService.sharedInstance.recieveUserData(onComplete: onComplete)
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
            imageViewProfile.image = image
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toEditProfileSegue",
            let editVC = segue.destination as? EditProfileViewController
        {
            editVC.callback = { user in
                self.user = user
                self.setupView(user: self.user)
            }
            
            guard let user = sender as? User else { return }
            editVC.user = user
        }
    }

    @IBAction func editProfileAction(_ sender: Any)
    {
        performSegue(withIdentifier: "toEditProfileSegue", sender: user)
    }
}
