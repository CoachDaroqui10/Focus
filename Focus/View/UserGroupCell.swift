//
//  UserGroupCell.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 02/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class UserGroupCell: UITableViewCell
{
    @IBOutlet weak var labelGroupName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setup(position: Int, name: String)
    {
        labelGroupName.text = name
        if position % 2 == 0
        {
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0125)
        }
        else
        {
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        }
        //Quitar
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
    }
}
