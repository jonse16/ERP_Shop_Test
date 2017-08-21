//
//  TempOrderItems.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/24.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation


class TempOrderItems{
    
    private static var toi:TempOrderItems?    
    var order = Order()
    
    func orderIni(currentUser:User){
        order = Order()
        order.id = UUID().uuidString
        order.companyId = currentUser.companyId
        order.uid = currentUser.uid
        order.status = 0
    }
    
    
    static func sharedInstance() -> TempOrderItems {
        if toi == nil {
            toi = TempOrderItems()
        }
        return toi!
    }
}
