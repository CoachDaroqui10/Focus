//
//  InvitesListViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 05/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit
import FirebaseAuth

class InvitesListViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!{
        didSet
        {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var listInvites : [Invite] = []
    var delete = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        tableView.tableFooterView = UIView()

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(false)
        
        tableView.tableFooterView = UIView()
        
        DatabaseService.sharedInstance.retrieveInvites(for: Auth.auth().currentUser!.uid, onComplete: onCompleteRecieve(invites:))
    }
    
    func onCompleteRecieve(invites: [Invite]?) -> Void
    {
        if let invites = invites
        {
            listInvites = invites
            tableView.reloadData()
        }
        else
        {
            print("Error obteniendo las invitaciones")
            listInvites = [Invite]()
            tableView.reloadData()
        }
    }
    
    func onCompleteJoin(error: Error?) -> Void
    {
        if error != nil
        {
            print("Error uniendose al grupo")
            let alert = UIAlertController(title: "Error uniendose al grupo", message: "No ha sido posible unirse al grupo seleccionado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("Unido correctamente")
            let alert = UIAlertController(title: "Unido correctamente", message: "Has sido añadido al grupo correctamente", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onCompleteDelete(error: Error?) -> Void
    {
        if error == nil
        {
            DatabaseService.sharedInstance.retrieveInvites(for: Auth.auth().currentUser!.uid, onComplete: onCompleteRecieve(invites:))
        }
    }
}

//Delegate
extension InvitesListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("Preparado para unirse al grupo")
        let alert = UIAlertController(title: "¿Quieres unirte al grupo?", message: "Pulsa Aceptar para unirte al grupo", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Aceptar", comment: "Default action"), style: .default, handler: { _ in
            
            NSLog("The \"OK\" alert occured.")
            DatabaseService.sharedInstance.joinGroupInvite(group: self.listInvites[indexPath.row].group, onComplete: self.onCompleteJoin(error:))
            

            DatabaseService.sharedInstance.deleteInvite(invite: self.listInvites[indexPath.row], onComplete: self.onCompleteDelete(error:))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Rechazar", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Invitación cancelada")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//Data source
extension InvitesListViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listInvites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "invitesCell", for: indexPath) as? InvitesCell
        {
            cell.setup(group: listInvites[indexPath.row].group)
            return cell
        }
        
        return InvitesCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
}
