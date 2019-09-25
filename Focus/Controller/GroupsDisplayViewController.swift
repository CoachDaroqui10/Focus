//
//  GroupsDisplayViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 23/08/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit
import FirebaseAuth

class GroupsDisplayViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!{
        didSet
        {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var listaGrupos : [Group] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Crear grupo", style: .plain, target: self, action: #selector(GroupsDisplayViewController.createGroupAction(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(false)
        
        DatabaseService.sharedInstance.retrieveAllUserGroups(for: Auth.auth().currentUser!.uid, onComplete: onComplete(grupos:))
    }
    
    func onComplete(grupos: [Group]?) -> Void
    {
        if let grupos = grupos
        {
            listaGrupos = grupos
            tableView.reloadData()
        }
        else
        {
            print("Error obteniendo grupos del usuario")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toGroupSegue",
            let groupVC = segue.destination as? GroupViewController
        {
            guard let selectedGroup = sender as? Group else { return }
            groupVC.group = selectedGroup
        }
    }

    @IBAction func createGroupAction(_ sender: Any)
    {
        print("Crear grupo pulsado")
        performSegue(withIdentifier: "createGroupSegue", sender: self)
    }
}

//Delegate
extension GroupsDisplayViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "toGroupSegue", sender: listaGrupos[indexPath.row])
    }
}

//Data source
extension GroupsDisplayViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listaGrupos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userGroupCell", for: indexPath) as? UserGroupCell
        {
            cell.setup(position: indexPath.row, name: listaGrupos[indexPath.row].name)
            return cell
        }
        
        return UserGroupCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
}

