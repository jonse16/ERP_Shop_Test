//
//  Report.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/4.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase

class Report{
    var id = String()
    var time = String()
    var total = Int()
    var discount = Int()
    var totalCount = Int()
    
    func converToReport(snapshot: DataSnapshot){
        let dataFormate = DateFormatter()
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for report in snapshot.children.allObjects as! [DataSnapshot]{
            switch report.key {
            case "id":
                id = report.value as! String
                break;
            case "createDateTime":
                time = report.value as! String
                break;
            case "total":
                total = report.value as! Int
                break;
            case "discount":
                discount = report.value as! Int
                break;
            case "totalCount":
                totalCount = report.value as! Int
                break;
            default: break
                
            }
        }
    }
}
