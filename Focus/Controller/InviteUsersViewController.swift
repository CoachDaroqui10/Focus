//
//  InviteUsersViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 04/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class InviteUsersViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!{
        didSet
        {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var group: Group = Group(dictionary: ["name": "", "imageURL" : ""])!
    var listUsers : [User] = []
    var userToInvite: User = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(false)
        
         DatabaseService.sharedInstance.searchUsers(onComplete: onCompleteUsers)
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
            print("Error obteniendo los usuarios")
        }
    }
    
    func onCompleteInvites(error: Error?) -> Void
    {
        if error != nil
        {
            print("Error invitando al usuario")
            let alert = UIAlertController(title: "Error invitando al usuario", message: "El usuario ya tiene una invitación pendiente para este grupo y ha sido notificado de ella.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            DatabaseService.sharedInstance.inviteUser(username: userToInvite.username, group: group.name)
            
            print("Invitación enviada")
            let alert = UIAlertController(title: "Usuario invitado correctamente", message: "La invitación ha sido enviada al usuario correctamente", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//Delegate
extension InviteUsersViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("Preparando invitación")
        let alert = UIAlertController(title: "¿Mandar invitación a \(listUsers[indexPath.row].username)", message: "Pulse aceptar si desea enviar la invitación al usuario seleccionado-", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Aceptar", comment: "Default action"), style: .default, handler: { _ in
            
            NSLog("The \"OK\" alert occured.")
            self.userToInvite = self.listUsers[indexPath.row]
            DatabaseService.sharedInstance.checkUserInGroup(username: self.userToInvite.username, group: self.group.name, onComplete: self.onCompleteInvites(error:))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Rechazar", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Invitación cancelada")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//Data source
extension InviteUsersViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "usersForInviteCell", for: indexPath) as? UsersForInviteCell
        {
            let position = indexPath.row
            let user = listUsers[position]
            cell.setup(position: position, username: user.username, name: user.name)
            return cell
        }
        
        return UsersForInviteCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
}

