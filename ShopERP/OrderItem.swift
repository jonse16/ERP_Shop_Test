//
//  OrderItem.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/18.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase

class OrderItem{
    
    var id = String()
    var productId = String()
    var productName = String()
    var count = Int()
    var total = Int()
    var orderId = String()
    var product:Product? = nil
    
    func converToArray() -> [String:Any]{
        return ["id":id,
                "productId":productId,
                "productName":productName,
                "count":count,
                "total":total,
                "orderId":orderId]
    }
    
    func converToOrderItem(map: Dictionary<String, Any>){
        for (key,value) in map{
            switch key {
            case "id":
                id = value as! String
                break;
            case "productId":
                productId = value as! String
                break;
            case "productName":
                productName = value as! String
                break;
            case "count":
                count = value as! Int
                break;
            case "total":
                total = value as! Int
                break;
            case "orderId":
                orderId = value as! String
                break;
            default:
                return;
            }
        }
    }
}
