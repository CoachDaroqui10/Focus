//
//  GroupViewController.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 02/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController
{
    @IBOutlet weak var labelGroupTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet
        {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var group: Group = Group(dictionary: ["name": "", "imageURL" : ""])!
    var listPosts : [Post] = []
    var postPic : UIImage = UIImage()
    
    lazy var refresher : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        
        refreshControl.addTarget(self, action: #selector(requestPosts), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        
        labelGroupTitle.text = group.name
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        
        tableView.refreshControl = refresher
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        DatabaseService.sharedInstance.retrieveGroupPosts(group: group, onComplete: onComplete(posts:))
    }
    
    @objc
    func requestPosts()
    {
        print("Recibiendo post en actualización")
        DatabaseService.sharedInstance.retrieveGroupPosts(group: group, onComplete: onComplete(posts:))
    }
    
    func onComplete(posts: [Post]?) -> Void
    {
        if let posts = posts
        {
            listPosts = posts
            listPosts = listPosts.reversed()
            tableView.reloadData()
            refresher.endRefreshing()
            //print(listPosts)
        }
        else
        {
            print("Error obteniendo los posts")
        }
    }
    
    func onCompletePic(image: UIImage?) -> Void
    {
        if let image = image
        {
            postPic = image
            print("La imagen obtenida es: \(postPic)")
        }
        else
        {
            print("Error obteniendo la imagen del post")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "createPublicationSegue",
            let postVC = segue.destination as? CreatePostViewController
        {
            guard let selectedGroup = sender as? Group else { return }
            postVC.group = selectedGroup
        }
        
        if segue.identifier == "inviteSegue",
            let inviteVC = segue.destination as? InviteUsersViewController
        {
            guard let selectedGroup = sender as? Group else { return }
            inviteVC.group = selectedGroup
        }
        
        if segue.identifier == "toGroupInfo",
            let groupVC = segue.destination as? GroupInfoViewController
        {
            groupVC.callback = { group in
                self.group = group
            }
            guard let selectedGroup = sender as? Group else { return }
            groupVC.group = selectedGroup
        }
    }
    
    @IBAction func createPostAction(_ sender: Any)
    {
        performSegue(withIdentifier: "createPublicationSegue", sender: group)
    }
    
    @IBAction func inviteAction(_ sender: Any)
    {
        performSegue(withIdentifier: "inviteSegue", sender: group)
    }
    
    @IBAction func groupAction(_ sender: Any)
    {
        performSegue(withIdentifier: "toGroupInfo", sender: group)
    }
}

extension GroupViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension GroupViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if listPosts[indexPath.row].image == ""
        {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "postGroupDisplayCell",
                for: indexPath) as? PostGroupDisplayCell
            {
                
                cell.setup(text: listPosts[indexPath.row].text, timestamp: listPosts[indexPath.row].timestamp.stringValue, user: listPosts[indexPath.row].username)
                return cell
            }
        }
        else
        {            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "postGroupImageDisplayCell",
                for: indexPath) as? PostGroupPicCell
            {
                //DatabaseService.sharedInstance.downloadPostImage(url: listPosts[indexPath.row].image, onComplete: onCompletePic(image:))
                
                DispatchQueue.main.async
                {
                    cell.setup(text: self.listPosts[indexPath.row].text, timestamp: self.listPosts[indexPath.row].timestamp.stringValue, user: self.listPosts[indexPath.row].username, image: self.listPosts[indexPath.row].image)
                }
                
                return cell
            }
        }
        
        return PostGroupDisplayCell()
    }
}
