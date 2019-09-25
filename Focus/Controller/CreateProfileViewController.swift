//
//  CreateProfileViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 31/07/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateProfileViewController: UIViewController
{
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var textFieldUsername: UITextField!

    var uName = ""
    var uLastName = ""
    var uUsername = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
    }
    
    func onComplete(boolean: Bool) -> Void
    {
        let register = boolean
        if register
        {
            DatabaseService.sharedInstance.registerUserData(userID: Auth.auth().currentUser!.uid, name: uName, lastName: uLastName, username: uUsername)
            performSegue(withIdentifier: "userCreatedSegue", sender: (Any).self)
        }
        else
        {
            print("Error registrando los datos")
            let alert = UIAlertController(title: "Usuario no disponible", message: "El nombre de usuario escogido ya existe, pruebe con otro", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func registerAction(_ sender: Any)
    {
        if let name = textFieldName.text
        {
            if let lastName = textFieldLastName.text
            {
                if let username = textFieldUsername.text
                {
                    uName = name
                    uLastName = lastName
                    uUsername = username
                    
                    DatabaseService.sharedInstance.checkUsername(username: uUsername, onComplete: onComplete(boolean:))
                }
            }
        }
    }
}
