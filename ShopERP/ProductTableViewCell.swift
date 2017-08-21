//
//  ProductTableViewCell.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/5.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {        
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var stock: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
