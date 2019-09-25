//
//  ViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 09/07/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
    }

    func onCompleteLogin (error: Error?) -> Void
    {
        if error != nil
        {
            print("Error autentificando")
            let alert = UIAlertController(title: "Error de autentificación", message: "No se ha podido autentificar el usuario, el usuario y/o la contraseña pueden ser erróneos o el usuario puede haber sido borrado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("Autentificado")
            performSegue(withIdentifier: "mainMenuSegue", sender: nil)
        }
    }
    
    func onCompleteRegister (error: Error?) -> Void
    {
        if error != nil
        {
            print("Error autentificando")
            let alert = UIAlertController(title: "Error de registro", message: "No se ha podido registrar el usuario. Compruebe que el correo es válido", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("Registrado y autentificado")
            performSegue(withIdentifier: "createUserSegue", sender: nil)
        }
    }
    
    @IBAction func loginAction(_ sender: Any)
    {
        if let usuario = textFieldEmail.text
        {
            if let contraseña = textFieldPassword.text
            {
                AuthenticationService.sharedInstance.loginUser(email: usuario, password: contraseña, onComplete: onCompleteLogin)
            }
        }
    }
    
    @IBAction func registerAction(_ sender: Any)
    {
        if let usuario = textFieldEmail.text
        {
            if let contraseña = textFieldPassword.text
            {
                AuthenticationService.sharedInstance.registerUser(email: usuario, password: contraseña, onComplete: onCompleteRegister)
            }
        }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any)
    {
        
    }
}

extension UIViewController
{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

