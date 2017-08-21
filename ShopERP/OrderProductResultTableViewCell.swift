//
//  OrderProductResultTableViewCell.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/20.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderProductResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var less: UIButton!
    var countInt = 0
    var product:Product? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
