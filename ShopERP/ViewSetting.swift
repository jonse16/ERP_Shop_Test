//
//  TitleBarSetting.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/14.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import UIKit

class ViewSetting{
    private static var viewSetting:ViewSetting?
    static func sharedInstance() -> ViewSetting{
        if viewSetting == nil {
            viewSetting = ViewSetting()
        }
        return viewSetting!
    }
    
    var styleColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1.0)
    var titleBarText = "主選單"
    var titleBarTextColor = UIColor.white
    var titleBackButtonIsHidden = true
    var titleHomeButtonIsHidden = true
    
    
    func setDefault(){
        styleColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1.0)
        titleBarText = "主選單"
        titleBarTextColor = UIColor.white
        titleBackButtonIsHidden = true
        titleHomeButtonIsHidden = true
    }
    
}
