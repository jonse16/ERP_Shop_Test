//
//  OrderItemTableViewCell.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/8.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var total: UILabel!    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
