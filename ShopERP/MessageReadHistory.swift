//
//  MessageReadHistory.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/10.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class MessageReadHistory : Object{
    private(set)  dynamic var id:String = UUID().uuidString
    dynamic var companyId:String = ""
    dynamic var uid:String = ""
    dynamic var name:String = ""
    dynamic var title:String = ""
    dynamic var body:String = ""
    dynamic var type:String = ""
    dynamic var type_id:String = ""
    dynamic var createDateTime:Date = Date()
    dynamic var readed:Bool = false
    
    //設置索引主鍵
    override static func primaryKey() -> String {
        return "id"
    }
    
    func converToMessageReadHistory(snapshot: DataSnapshot){
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for data in snapshot.children.allObjects as! [DataSnapshot]{
            switch data.key {
            case "name":
                name = data.value as! String
                break;
            case "title":
                title = data.value as! String
                break;
            case "body":
                body = data.value as! String
                break;
            case "id":
                id = data.value as! String
                break;
            case "careteDateTime":
                var timestemp = data.value as! Double
                timestemp = timestemp / 1000
                createDateTime = Date(timeIntervalSince1970: timestemp)
                dataFormate.timeZone = TimeZone.current
                let p = dataFormate.string(from: createDateTime)
                createDateTime = dataFormate.date(from: p)!
                break;
            case "readed":
                if let readedString = data.value as? String{
                    if readedString == "true"{
                        readed = true
                    }else{
                        readed = false
                    }
                }
                break;
            default:
                return;
            }
        }
    }

}
