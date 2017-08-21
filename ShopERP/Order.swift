//
//  Order.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/17.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase

class Order{
    var id = String()
    var companyId = String()
    var createDateTime = Date()
    var uid = String()
    var user_name =  String()
    var year = Int()
    var month = Int()
    var day = Int()
    var items = [OrderItem]()
    var totalCount = Int()
    var discount = Int()
    var total = Int()
    // 0 newOrder
    // 1 pay and finish
    // 4 cancel
    var status = Int()
    
    func converToArray() -> [String:Any]{
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return ["id":id,
                "companyId":companyId,
                "createDateTime":dataFormate.string(from: createDateTime),
                "uid":uid,
                "user_name":user_name,
                "year":year,
                "month":month,
                "day":day,
                "items":getItemsArray(),
                "totalCount":totalCount,
                "discount":discount,
                "total":total,
                "status":status]
    }
    
    func getItemsArray() -> [[String:Any]]{
        var array = [[String:Any]]()
        for item in items{
            array.append(item.converToArray())
        }
        return array
    }
    
    func converToOrder(snapshot: DataSnapshot){
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for data in snapshot.children.allObjects as! [DataSnapshot]{
            switch data.key {
            case "id":
                id = data.value as! String
                break;
            case "companyId":
                companyId = data.value as! String
                break;
            case "createDateTime":
                createDateTime = dataFormate.date(from: data.value as! String)!
                break;
            case "uid":
                uid = data.value as! String
                break;
            case "user_name":
                user_name = data.value as! String
                break;
            case "year":
                year = data.value as! Int
                break;
            case "month":
                month = data.value as! Int
                break;
            case "day":
                day = data.value as! Int
                break;
            case "items":
                let itemNSArray = data.value as! NSArray
                for item in itemNSArray{
                    let orderItem = OrderItem()
                    let itemMap = item as! Dictionary<String, Any>
                    orderItem.converToOrderItem(map: itemMap)
                    items.append(orderItem)
                }
                break;
            case "totalCount":
                totalCount = data.value as! Int
                break;
            case "discount":
                discount = data.value as! Int
                break;
            case "total":
                total = data.value as! Int
                break;
            case "status":
                status = data.value as! Int
                break;
            default:
                return;
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
