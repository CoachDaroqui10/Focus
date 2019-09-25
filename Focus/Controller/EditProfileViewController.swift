//
//  EditProfileViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 18/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UINavigationControllerDelegate
{
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldDescription: UITextView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    var user = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
    var newUser = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
    
    var callback : ((User) -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        
        print(user)
        
        textFieldName.text = user.name
        textFieldLastName.text = user.lastName
        textFieldUsername.text = user.username
        
        //Placeholder campo de edición de texto
        textFieldDescription.layer.borderWidth = 0.5
        textFieldDescription.layer.borderColor = UIColor.gray.cgColor
        textFieldDescription.layer.cornerRadius = 5
        if user.description == ""
        {
            textFieldDescription.text = "Escribe tu descripción..."
            textFieldDescription.textColor = UIColor.lightGray
        }
        else
        {
            textFieldDescription.text = user.description
        }
        
        DatabaseService.sharedInstance.downloadUserImage(user: self.user, onComplete: onCompletePic(image:))
    }
    
    //Placeholder campo de edición de texto
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Escribe tu descripción..." {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Escribe tu descripción..."
            textView.textColor = UIColor.lightGray
        }
    }
    ////
    
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
    
    func onCompleteCheck(boolean: Bool) -> Void
    {
        let register = boolean
        if register
        {
            
            if newUser.imageUrl == ""
            {
                DatabaseService.sharedInstance.updateUserDataNoPic(user: newUser)
            }
            else
            {
                let imgData = imageViewProfile.image?.pngData()
                DatabaseService.sharedInstance.updateUserDataWithPic(user: newUser, picture: imgData!)
            }
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
    
    @IBAction func actionGuardar(_ sender: Any)
    {
        if user.name != textFieldName.text
        {
            newUser.name = textFieldName.text!
        }
        else
        {
            newUser.name = user.name
        }
        
        if user.lastName != textFieldLastName.text
        {
            newUser.lastName = textFieldLastName.text!
        }
        else
        {
            newUser.lastName = user.lastName
        }
        
        if user.username != textFieldUsername.text
        {
            newUser.username = textFieldUsername.text!
        }
        else
        {
            newUser.username = user.username
        }
        
        if user.description != textFieldDescription.text
        {
            newUser.description = textFieldDescription.text!
        }
        else
        {
            newUser.description = user.description
        }
        
        
        if imageViewProfile.image == UIImage(named: "logo")
        {
            newUser.imageUrl = ""
            if newUser.username != user.username
            {
                DatabaseService.sharedInstance.checkUsername(username: newUser.username, onComplete: onCompleteCheck(boolean:))
            }
            else
            {
                DatabaseService.sharedInstance.updateUserDataNoPic(user: newUser)
            }
        }
        else
        {
            newUser.imageUrl = "Foto"
            if newUser.username != user.username
            {
                DatabaseService.sharedInstance.checkUsername(username: newUser.username, onComplete: onCompleteCheck(boolean:))
            }
            else
            {
                let imgData = imageViewProfile.image?.pngData()
                DatabaseService.sharedInstance.updateUserDataWithPic(user: newUser, picture: imgData!)
            }
        }
        
        self.callback?(self.newUser)
    }
    
    @IBAction func actionImagen(_ sender: Any)
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        
        let actionSheet = UIAlertController(title: "Recurso de la imagen", message: "Seleccione un recurso para obtener la imagen", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cámara", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Carrete", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageViewProfile.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
