//
//  MessageProductTableViewCell.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/15.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class MessageProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var body: UILabel!
    
    @IBOutlet weak var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
