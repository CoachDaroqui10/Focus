//
//  PostGroupPicCell.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 16/09/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import UIKit
import SDWebImage

class PostGroupPicCell: UITableViewCell
{
    @IBOutlet weak var labelPostText: UILabel!
    @IBOutlet weak var labelPostDate: UILabel!
    @IBOutlet weak var labelPostUser: UILabel!
    @IBOutlet weak var imageViewPostPic: UIImageView!
    
    var fullName = ""
    var postPic = UIImage()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func onCompletePic(image: UIImage?) -> Void
    {
        if let image = image
        {
            imageViewPostPic.image = image
            print("La imagen obtenida es: \(imageViewPostPic.image)")
        }
        else
        {
            print("Error obteniendo la imagen del post")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setup(text: String, timestamp: String, user: String, image: String)
    {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        
        let date =  NSNumber(value: Double(timestamp)!)
        let exactDate = NSDate(timeIntervalSince1970: TimeInterval(truncating: date))
        let dateFormatt = DateFormatter()
        dateFormatt.dateFormat = "dd/MM/yyy hh:mm a"
        
        print("La imagen del post es: \(image)")
        
        imageViewPostPic.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "logo"))
        
        labelPostText.text = text
        labelPostDate.text = dateFormatt.string(from: exactDate as Date)
        labelPostUser.text = user
    }
}
