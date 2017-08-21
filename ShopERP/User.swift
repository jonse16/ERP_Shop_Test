//
//  User.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/17.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase

class User{
    var uid = String()
    var name = String()
    var companyId = String()
    var phone = String()
    var address = String()
    var email = String()
    var title = String()
    var createDateTime = Date()
    var updateDateTime = Date()
    var validate = false
    var enable = true
    var deleted = false
    
    func converToArray() -> [String:String]{
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return ["uid":uid,
                "name":name,
                "companyId":companyId,
                "phone":phone,
                "address":address,
                "email":email,
                "title":title,
                "createDateTime":dataFormate.string(from: createDateTime),
                "updateDateTime":dataFormate.string(from: updateDateTime),
                "validate":validate.description,
                "enable":enable.description,
                "deleted":deleted.description]
    }
    
    
    func converToUser(snapshot: DataSnapshot){
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for userData in snapshot.children.allObjects as! [DataSnapshot]{
            switch userData.key {
            case "uid":
                uid = userData.value as! String
                break;
            case "name":
                name = userData.value as! String
                break;
            case "companyId":
                companyId = userData.value as! String
                break;
            case "phone":
                phone = userData.value as! String
                break;
            case "address":
                address = userData.value as! String
                break;
            case "email":
                email = userData.value as! String
                break;
            case "title":
                title = userData.value as! String
                break;
            case "createDateTime":
                createDateTime = dataFormate.date(from: userData.value as! String)!
                break;
            case "updateDateTime":
                updateDateTime = dataFormate.date(from: userData.value as! String)!
                break;
            case "validate":
                if let validateString = userData.value as? String{
                    if validateString == "true"{
                        validate = true
                    }else{
                        validate = false
                    }
                }
                break;
            case "enable":
                if let enableString = userData.value as? String{
                    if enableString == "true"{
                        enable = true
                    }else{
                        enable = false
                    }
                }
                break;
            case "deleted":
                if let deletedString = userData.value as? String{
                    if deletedString == "true"{
                        deleted = true
                    }else{
                        deleted = false
                    }
                }
                break;
            default:
                return;
            }
        }
    }
}
