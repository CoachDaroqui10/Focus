//
//  postGroupDisplayCell.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 05/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit

class PostGroupDisplayCell: UITableViewCell
{
    @IBOutlet weak var labelPostText: UILabel!
    @IBOutlet weak var labelPostDate: UILabel!
    @IBOutlet weak var labelPostUser: UILabel!
    
    var fullName = ""
    
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
    
    func setup(text: String, timestamp: String, user: String)
    {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        
        let date =  NSNumber(value: Double(timestamp)!)
        let exactDate = NSDate(timeIntervalSince1970: TimeInterval(truncating: date))
        let dateFormatt = DateFormatter()
        dateFormatt.dateFormat = "dd/MM/yyy hh:mm a"
        
        labelPostText.text = text
        labelPostDate.text = dateFormatt.string(from: exactDate as Date)
        labelPostUser.text = user
    }
}
