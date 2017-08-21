//
//  Product.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/29.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase

class Product{
    var id = String()
    var name = String()
    var companyId = String()
    var productCategoryId = String()
    var barcode = String()
    var price = Int()
    var list_price = Int()
    //目前庫存
    var stock = false
    var stock_count = Int()
    //是否開啟庫存提醒
    var reminder_stock = false
    //庫存提醒數量
    var reminder_stock_count = Int()
    //是否有賣出的紀錄 如果沒有 直接刪除 有的話要報表留底
    var once_sold = false
    var enable = false
    var deleted = false
    var sort = Int()
    var parent:ProductCategory? = nil
    
    //    var picArray = [String]()
    
    func converToArray() -> [String:Any]{
        return ["id":id,
                "name":name,
                "companyId":companyId,
                "productCategoryId":productCategoryId,
                "barcode":barcode,
                "price":price,
                "list_price":list_price,
                "stock":stock.description,
                "stock_count":stock_count,
                "reminder_stock":reminder_stock.description,
                "reminder_stock_count":reminder_stock_count,
                "once_sold":once_sold.description,
                "enable":enable.description,
                "deleted":deleted.description,
                "sort":sort]
    }
    
    func converToProduct(snapshot: DataSnapshot){
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for data in snapshot.children.allObjects as! [DataSnapshot]{
            switch data.key {
            case "id":
                id = data.value as! String
                break;
            case "name":
                name = data.value as! String
                break;
            case "companyId":
                companyId = data.value as! String
                break;
            case "productCategoryId":
                productCategoryId = data.value as! String
                break;
            case "barcode":
                barcode = data.value as! String
                break;
            case "price":
                price = data.value as! Int
                break;
            case "list_price":
                list_price = data.value as! Int
                break;
            case "stock":
                if let stockString = data.value as? String{
                    if stockString == "true"{
                        stock = true
                    }else{
                        stock = false
                    }
                }
                break;
            case "stock_count":
                stock_count = data.value as! Int
                break;
            case "reminder_stock":
                if let reminder_stockString = data.value as? String{
                    if reminder_stockString == "true"{
                        reminder_stock = true
                    }else{
                        reminder_stock = false
                    }
                }
                break;
            case "reminder_stock_count":
                reminder_stock_count = data.value as! Int
                break;
            case "once_sold":
                if let once_soldString = data.value as? String{
                    if once_soldString == "true"{
                        once_sold = true
                    }else{
                        once_sold = false
                    }
                }
                break;
                
            case "enable":
                if let enableString = data.value as? String{
                    if enableString == "true"{
                        enable = true
                    }else{
                        enable = false
                    }
                }
                break;
            case "deleted":
                if let deletedString = data.value as? String{
                    if deletedString == "true"{
                        deleted = true
                    }else{
                        deleted = false
                    }
                }
                break;
            case "sort":
                sort = data.value as! Int
                break;
            default:
                return;
            }
        }
    }
    
    func copy() -> Product{
    let newProduct = Product()
        newProduct.barcode = barcode
        newProduct.companyId = companyId
        newProduct.enable = enable
        newProduct.id = id
        newProduct.list_price = list_price
        newProduct.name = name
        newProduct.parent = parent
        newProduct.price = price
        newProduct.productCategoryId = productCategoryId
        newProduct.reminder_stock = reminder_stock
        newProduct.sort = sort
        newProduct.stock = stock
        newProduct.stock_count = stock_count
        return newProduct
    }
}
