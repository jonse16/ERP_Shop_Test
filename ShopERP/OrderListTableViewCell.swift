//
//  OrderListTableViewCell.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/8.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
