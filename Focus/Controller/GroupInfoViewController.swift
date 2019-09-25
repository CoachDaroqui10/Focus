//
//  GroupInfoViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 09/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class GroupInfoViewController: UIViewController, UINavigationControllerDelegate
{
    @IBOutlet weak var imageViewGroupPicture: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet
        {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var labelGroupName: UILabel!
    
    var group: Group = Group(dictionary: ["name": "", "imageURL" : ""])!
    var listUsers : [User] = []
    
    var callback : ((Group) -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DatabaseService.sharedInstance.downloadGroupImage(group: group, onComplete: onCompletePic(image:))
        
        labelGroupName.text = group.name
        
        DatabaseService.sharedInstance.getAllGroupUsers(group: group, onComplete: onCompleteUsers(users:))
        
        tableView.tableFooterView = UIView()
    }
    

    
    func onCompletePic(image: UIImage?) -> Void
    {
        if let image = image
        {
            imageViewGroupPicture.image = image
        }
        else
        {
            print("Error obteniendo la imagen del grupo")
        }
    }
    
    func onCompleteLeave(error: Error?) -> Void
    {
        if error == nil
        {
            print("Saliendo correctamente")
        }
        else
        {
            print("Error abandonando el grupo")
        }
    }
    
    func onCompleteUsers(users: [User]?) -> Void
    {
        if let users = users
        {
            listUsers = users
            tableView.reloadData()
        }
        else
        {
            print("Error obteniendo usuarios del grupo")
        }
    }
    
    @IBAction func leaveGroupAction(_ sender: Any)
    {
        print("Preparado para salirse al grupo")
        let alert = UIAlertController(title: "¿Quieres abandonar al grupo?", message: "Pulsa Aceptar para abandonar al grupo", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Aceptar", comment: "Default action"), style: .default, handler: { _ in
            
            NSLog("The \"OK\" alert occured.")
            
            DatabaseService.sharedInstance.leaveGroup(group: self.group, onComplete: self.onCompleteLeave(error:))
            
            self.performSegue(withIdentifier: "backFromGroupInfo", sender: sender)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Rechazar", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Abandono cancelado")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func inviteAction(_ sender: Any)
    {
        performSegue(withIdentifier: "toInviteFromGroupInfo", sender: group)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toInviteFromGroupInfo",
            let inviteVC = segue.destination as? InviteUsersViewController
        {
            guard let selectedGroup = sender as? Group else { return }
            inviteVC.group = selectedGroup
        }
        
        if segue.identifier == "toInviteFromGroupInfo",
            let inviteVC = segue.destination as? InviteUsersViewController
        {
            guard let selectedGroup = sender as? Group else { return }
            inviteVC.group = selectedGroup
        }
        
        if segue.identifier == "toUserProfileSegue",
            let profileVC = segue.destination as? GroupUserProfileViewController
        {
            guard let selectedUser = sender as? User else { return }
            profileVC.user = selectedUser
        }
    }
    
    @IBAction func changeImageAction(_ sender: Any)
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
    
    @IBAction func changeNameAction(_ sender: Any)
    {
        let alert = UIAlertController(title: "Cambiando el nombre", message: "Introduce el nuevo nombre del grupo", preferredStyle: .alert)
        
        alert.addTextField
        { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if let newName = textField?.text
            {
                DatabaseService.sharedInstance.changeGroupName(group: self.group, name: newName)
                self.group.name = newName
                self.callback?(self.group)
                self.labelGroupName.text = newName
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//Delegate
extension GroupInfoViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        performSegue(withIdentifier: "toUserProfileSegue", sender: listUsers[indexPath.row])
    }
}

//Data source
extension GroupInfoViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "groupUserCell", for: indexPath) as? GroupUserCell
        {
            let position = indexPath.row
            let user = listUsers[position]
            cell.setup(position: position, name: user.name)
            return cell
        }
        
        return UsersForInviteCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
}

extension GroupInfoViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageViewGroupPicture.image = pickedImage
            
            DatabaseService.sharedInstance.updateGroupPic(group: group, picture: pickedImage.pngData()!)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
