//
//  CompanyCellTableViewCell.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/20.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class CompanyCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
