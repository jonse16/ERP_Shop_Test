//
//  ProductCategory.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/26.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase

class ProductCategory{
    
    var id = String()
    var name = String()
    var parentId = String()
    var childrenCategoryCount = Int()
    var childrenProductCount = Int()
    var sort = Int()
    var parent:ProductCategory? = nil
    
    func converToArray() -> [String:Any]{
        return ["id":id,
                "name":name,
                "parentId":parentId,
                "childrenCategoryCount":childrenCategoryCount,
                "childrenProductCount":childrenProductCount,
                "sort":sort]
    }
    
    func converToProductCategory(snapshot: DataSnapshot){
        
        for productCategoryData in snapshot.children.allObjects as! [DataSnapshot]{
            switch productCategoryData.key {
            case "id":
                id = productCategoryData.value as! String
                break;
            case "name":
                name = productCategoryData.value as! String
                break;
            case "parentId":
                parentId = productCategoryData.value as! String
                break;
            case "childrenCategoryCount":
                childrenCategoryCount = productCategoryData.value as! Int
                break;
            case "childrenProductCount":
                childrenProductCount = productCategoryData.value as! Int
                break;
            case "sort":
                sort = productCategoryData.value as! Int
                break;
            default:
                return;
            }
        }
    }
}
