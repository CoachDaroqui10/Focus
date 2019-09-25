//
//  CreatePostViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 02/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var textFieldPostText: UITextView!{
        didSet
        {
            textFieldPostText.delegate = self
        }
    }
    @IBOutlet weak var imagePickerPostPic: UIImageView!
    
    var group: Group = Group(dictionary: ["name": "", "imageURL" : ""])!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        
        //Placeholder campo de edición de texto
        textFieldPostText.text = "Escribe tu publicación..."
        textFieldPostText.textColor = UIColor.lightGray
        
    }
    
    //Placeholder campo de edición de texto
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Escribe tu publicación..."
            textView.textColor = UIColor.lightGray
        }
    }
    ////
    
    func onComplete(fullname: String?) -> Void
    {
        if imagePickerPostPic.image == nil
        {
            DatabaseService.sharedInstance.createPost(fullname: fullname!, group: group, text: textFieldPostText.text)
        }
        else
        {
            DatabaseService.sharedInstance.createPostWithPic(fullname: fullname!, group: group, text: textFieldPostText.text, picture: (imagePickerPostPic!.image?.pngData())!)
        }
        print("Publicado con éxito")
        let alert = UIAlertController(title: "¡Hecho!", message: "Se ha realizado la publicación en el grupo", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func actionCreatePost(_ sender: Any)
    {
        DatabaseService.sharedInstance.getDataForPost(onComplete: onComplete(fullname:))
    }
}

extension CreatePostViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imagePickerPostPic.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
