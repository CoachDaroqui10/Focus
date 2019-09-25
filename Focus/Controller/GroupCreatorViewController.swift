//
//  GroupCreatorViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 23/08/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class GroupCreatorViewController: UIViewController, UINavigationControllerDelegate
{
    @IBOutlet weak var imagePickerGroupImage: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    var groupCreated = Group(dictionary: ["name": "", "imageURL" : ""])!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
    }
    
    func onComplete (error: Error?) -> Void
    {
        if error != nil
        {
            print("Error creando grupo")
            let alert = UIAlertController(title: "Error creando grupo", message: "El grupo no ha podido ser creado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("Grupo creado")
            let alert = UIAlertController(title: "Grupo creado", message: "El grupo ha sido creado correctamente", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                self.performSegue(withIdentifier: "backToGroupsListSegue", sender: (Any).self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func imagePickerAction(_ sender: Any)
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
    
    @IBAction func createGroupAction(_ sender: Any)
    {
        print("Añadiendo grupo")
        
        if let groupName = groupNameTextField.text
        {
            if let groupImage = imagePickerGroupImage.image
            {
                if let data = groupImage.pngData()
                {
                    
                    DatabaseService.sharedInstance.createGroup(name: groupName, picture: data, onComplete: onComplete(error: ))
                }
            }
        }
    }
}

extension GroupCreatorViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imagePickerGroupImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
