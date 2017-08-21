//
//  Company.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/17.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation

class Company{
    var id:String!
    var name = String()
    //公司統一編號
    var ein_number = String()
    var phone = String()
    var address = String()
    var ownerUid = String()
    var createDateTime = Date()
    var updateDateTime = Date()
    
    func converToArray() -> [String:String]{
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return ["name":name,
                "ein_number":ein_number,
                "phone":phone,
                "address":address,
                "ownerUid":ownerUid,
        "createDateTime":dataFormate.string(from: createDateTime),
        "updateDateTime":dataFormate.string(from: updateDateTime)]
    }
}
