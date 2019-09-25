//
//  InvitesCell.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 05/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class InvitesCell: UITableViewCell
{
    @IBOutlet weak var labelGroupInvite: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(group: String)
    {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        labelGroupInvite.text = group
    }
}
