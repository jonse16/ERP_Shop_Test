//
//  DataService.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/21.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import RealmSwift

class DataService{
    
    private static var dataService:DataService?
    
    static func sharedInstance() -> DataService {
        if dataService == nil {
            dataService = DataService()
        }
        return dataService!
    }
    
    var timer:Timer!
    
    var ref : DatabaseReference?
    
    var companyId = ""
    
    var currentUser:User? = nil
    var loadIngCurrentUser = false
    var companyUsers = [User]()
    var loadIngCompanyAllUser = false
    var productCategorys = [ProductCategory]()
    var loadIngProductCategorys = false
    var products = [Product]()
    var loadIngProduct = false
    var orderProductResult = [Product]()
    var loadIngFindProductByCode = false
    var report = [Report]()
    var loadIngReport = false
    var order = [Order]()
    var loadIngOrder = false
    
    func isValidInternet () -> Bool{
        let reachability = Reachability(hostName: "www.apple.com")
        if reachability?.currentReachabilityStatus().rawValue == 0{
            print("no internet")
            return false;
        }
        return true
    }
    
    func getCurrentUser(){
        ref = Database.database().reference()
        self.currentUser = nil
        companyId = ""
        loadIngCurrentUser = true
        let uid = Auth.auth().currentUser?.uid
        //看看 uid 存不存在於users table 如果沒有 執行下列程式
        ref?.child("users").observeSingleEvent(of: .value, with: {
            (snapshot) in
            if snapshot.hasChild(uid!){
                let result =  self.ref?.child("users").child(uid!)
                result?.observe(.value, with: {
                    (snapshot: DataSnapshot) in
                    if(snapshot.childrenCount > 0){
                        let user = User()
                        user.converToUser(snapshot: snapshot)
                        self.currentUser = user
                        self.companyId = user.companyId
                        self.loadIngCurrentUser = false
                    }else{
                        //data error
                        self.loadIngCurrentUser = false
                    }
                })
            }
        })
    }
    
    func getCompanyAllUser(){
        ref = Database.database().reference()
        print("start getCompanyAllUser() ============")
        loadIngCompanyAllUser = true
        if companyId != ""{
            self.ref?.child("companyUsers").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    let result =  self.ref?.child("companyUsers").child(self.companyId).queryOrdered(byChild: "deleted").queryEqual(toValue: "false")
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        print("getCompanyAllUser() snapshot.childrenCount = \(snapshot.childrenCount)")
                        if snapshot.childrenCount == 0{
                            self.companyUsers = self.iniUsers()
                            self.loadIngCompanyAllUser = false
                        }else{
                            self.companyUsers.removeAll()
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                let userData = snapshot.childSnapshot(forPath: String(rest.key))
                                let parserUser = User()
                                parserUser.converToUser(snapshot: userData)
                                self.companyUsers.append(parserUser)
                            }
                            self.companyUsers = self.iniUsers()
                            self.loadIngCompanyAllUser = false
                        }
                    })
                }
            })
        }else{
            self.companyUsers = self.iniUsers()
            self.loadIngCompanyAllUser = false
        }
        print("end getCompanyAllUser() ============")
    }
    
    //    func getProductCategorys(parentId:String){
    //        ref = Database.database().reference()
    //        print("start getProductCategorys() ============")
    //        loadIngProductCategorys = true
    //        if companyId != ""{
    //            self.ref?.child("productCategorys").observeSingleEvent(of: .value, with: {
    //                (snapshot) in
    //                if snapshot.hasChild(self.companyId){
    //                    //有了  判斷是否 被刪除 or 停用！！
    //                    let result =  self.ref?.child("productCategorys").child(self.companyId).queryOrdered(byChild: "parentId").queryEqual(toValue: parentId)
    //                    result?.observe(.value, with: {
    //                        (snapshot: DataSnapshot) in
    //                        self.productCategorys.removeAll()
    //                        if snapshot.childrenCount == 0{
    //                            self.loadIngProductCategorys = false
    //                        }else{
    //                            let enumerator = snapshot.children
    //                            var dictionary = [Int:ProductCategory]()
    //                            while let rest = enumerator.nextObject() as? DataSnapshot {
    //                                let productCategoryData = snapshot.childSnapshot(forPath: String(rest.key))
    //                                let parserproductCategory = ProductCategory()
    //                                parserproductCategory.converToProductCategory(snapshot: productCategoryData)
    //                                dictionary[parserproductCategory.sort] = parserproductCategory
    //                            }
    //                            var keyArray = Array(dictionary.keys)
    //                            keyArray.sort(by: <)
    //                            for item in keyArray{
    //                                self.productCategorys.append(dictionary[item]!)
    //                            }
    //                            self.loadIngProductCategorys = false
    //                        }
    //                    })
    //                }else{
    //                    self.loadIngProductCategorys = false
    //                }
    //            })
    //        }else{
    //            self.loadIngProductCategorys = false
    //        }
    //        print("end getProductCategorys() ============")
    //    }
    
    func getProductCategorys(parentId:String){
        ref = Database.database().reference()
        print("start getProductCategorys() ============")
        loadIngProductCategorys = true
        var dictionary = [Int:ProductCategory]()
        for item in allProductCategory{
            if item.parentId == parentId{
                dictionary[item.sort] = item
            }
        }
        self.productCategorys.removeAll()
        var keyArray = Array(dictionary.keys)
        keyArray.sort(by: <)
        for item in keyArray{
            self.productCategorys.append(dictionary[item]!)
        }
        self.loadIngProductCategorys = false
        print("end getProductCategorys() ============")
    }
    
    func getProduct(parentId:String){
        ref = Database.database().reference()
        print("start getProduct() ============")
        loadIngProduct = true
        self.products.removeAll()
        if companyId != ""{
            self.ref?.child("companyProduct").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    let result =  self.ref?.child("companyProduct").child(self.companyId).child(parentId)
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        if snapshot.childrenCount == 0{
                            self.loadIngProduct = false
                        }else{
                            let enumerator = snapshot.children
                            var dictionary = [Int:Product]()
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                let productData = snapshot.childSnapshot(forPath: String(rest.key))
                                let parserProduct = Product()
                                parserProduct.converToProduct(snapshot: productData)
                                dictionary[parserProduct.sort] = parserProduct
                            }
                            var keyArray = Array(dictionary.keys)
                            keyArray.sort(by: <)
                            for item in keyArray{
                                self.products.append(dictionary[item]!)
                            }
                            self.loadIngProduct = false
                        }
                    })
                }else{
                    self.loadIngProduct = false
                }
            })
        }else{
            self.loadIngProduct = false
        }
        print("end getProduct() ============")
    }
    
    func iniUsers() -> [User]{
        
        let userData = companyUsers
        var bossUser = [User]()
        var managerUser = [User]()
        var empUser = [User]()
        
        for user in userData{
            if(user.title == "boss"){
                bossUser.append(user)
            }
            if(user.title == "manager"){
                managerUser.append(user)
            }
            if(user.title == "emp"){
                empUser.append(user)
            }
        }
        
        let headerBoss = User()
        headerBoss.name = "老闆"
        headerBoss.title = "boss"
        let headerManager = User()
        headerManager.name = "經理（店長）"
        headerManager.title = "manager"
        let headerEmp = User()
        headerEmp.name = "職員"
        headerEmp.title = "emp"
        
        var newUsers = [User]()
        newUsers.append(headerBoss)
        newUsers.append(contentsOf: bossUser)
        newUsers.append(headerManager)
        newUsers.append(contentsOf: managerUser)
        newUsers.append(headerEmp)
        newUsers.append(contentsOf: empUser)
        
        return newUsers
    }
    
    func findProduct(by: String, value:String){
        ref = Database.database().reference()
        print("start findProduct() ============")
        loadIngFindProductByCode = true
        if companyId != ""{
            self.ref?.child("product").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    let result =  self.ref?.child("product").child(self.companyId).queryOrdered(byChild: by).queryEqual(toValue: value)
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        self.orderProductResult.removeAll()
                        if snapshot.childrenCount == 0{
                            self.loadIngFindProductByCode = false
                        }else{
                            let enumerator = snapshot.children
                            var dictionary = [Int:Product]()
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                let productData = snapshot.childSnapshot(forPath: String(rest.key))
                                let parserProduct = Product()
                                parserProduct.converToProduct(snapshot: productData)
                                if parserProduct.enable == true && parserProduct.deleted == false{
                                    dictionary[parserProduct.sort] = parserProduct
                                }
                            }
                            var keyArray = Array(dictionary.keys)
                            keyArray.sort(by: <)
                            for item in keyArray{
                                self.orderProductResult.append(dictionary[item]!)
                            }
                            self.loadIngFindProductByCode = false
                        }
                    })
                }else{
                    self.loadIngFindProductByCode = false
                }
            })
        }else{
            self.loadIngFindProductByCode = false
        }
    }
    //------------------------------------------------------------------------------------------
    func getReport(type:String, year:String, month:String, day:String, userId:String){
        if type == "day"{
            //child order
            getReportFromOrder(year: year, month: month, day: day, userId: userId)
        }else if type == "month"{
            if userId == ""{
                //child order_day_total
                getReportFromOrderDayTotal(year: year, month: month)
            }else{
                //child user_order_day_total
                getReportFromUserOrderDayTotal(year: year, month: month, userId: userId)
            }
        }else if type == "year" || type == "all"{
            if userId == ""{
                //child order_day_month
                getReportFromOrderMonthTotal(year: year)
            }else{
                //child user_order_day_month
                getReportFromUserOrderMonthTotal(year: year, userId: userId)
            }
        }
    }
    
    func getOrder(year:String, month:String, day:String){
        ref = Database.database().reference()
        print("start getOrder() ============")
        loadIngOrder = true
        self.order.removeAll()
        if companyId != ""{
            self.ref?.child("order/alive").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    let result =  self.ref?.child("order/alive").child(self.companyId).child(year).child(month).child(day)
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        if snapshot.childrenCount == 0{
                            self.loadIngOrder = false
                        }else{
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                let data = snapshot.childSnapshot(forPath: String(rest.key))
                                let parserOrder = Order()
                                parserOrder.converToOrder(snapshot: data)
                                self.order.append(parserOrder)
                            }
                            //逆排
                            self.order = self.order.reversed()
                            self.loadIngOrder = false
                        }
                    })
                }else{
                    self.loadIngOrder = false
                }
            })
        }else{
            loadIngOrder = false
        }
        print("end getOrder() ============")
    }
    
    func getReportFromOrder(year:String, month:String, day:String, userId:String){
        ref = Database.database().reference()
        print("start getReportFromOrder() ============")
        print("start getReportFromOrder() userId = \(userId)")
        loadIngReport = true
        if companyId != ""{
            self.ref?.child("order/alive").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    self.report.removeAll()
                    if userId != ""{
                        let result = self.ref?.child("order/alive").child(self.companyId).child(year).child(month).child(day).queryOrdered(byChild: "uid").queryEqual(toValue: userId)
                        result?.observe(.value, with: {
                            (snapshot: DataSnapshot) in
                            print("getReportFromOrder snapshot.childrenCount = \(snapshot.childrenCount)")
                            if snapshot.childrenCount == 0{
                                self.loadIngReport = false
                            }else{
                                let enumerator = snapshot.children
                                while let rest = enumerator.nextObject() as? DataSnapshot {
                                    let data = snapshot.childSnapshot(forPath: String(rest.key))
                                    let parserReport = Report()
                                    parserReport.converToReport(snapshot: data)
                                    self.report.append(parserReport)
                                }
                                self.loadIngReport = false
                            }
                        })
                    }else{
                        let result = self.ref?.child("order/alive").child(self.companyId).child(year).child(month).child(day)
                        result?.observe(.value, with: {
                            (snapshot: DataSnapshot) in
                            print("getReportFromOrder snapshot.childrenCount = \(snapshot.childrenCount)")
                            if snapshot.childrenCount == 0{
                                self.loadIngReport = false
                            }else{
                                let enumerator = snapshot.children
                                while let rest = enumerator.nextObject() as? DataSnapshot {
                                    let data = snapshot.childSnapshot(forPath: String(rest.key))
                                    let parserReport = Report()
                                    parserReport.converToReport(snapshot: data)
                                    self.report.append(parserReport)
                                }
                                self.loadIngReport = false
                            }
                        })
                    }
                    
                    
                    
                }else{
                    self.loadIngReport = false
                }
            })
        }else{
            loadIngReport = false
        }
        print("end getReportFromOrder() ============")
    }
    
    func getReportFromOrderDayTotal(year:String, month:String){
        ref = Database.database().reference()
        print("start getReportFromOrderDayTotal() ============")
        loadIngReport = true
        if companyId != ""{
            self.ref?.child("order_day_total").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    let result =  self.ref?.child("order_day_total").child(self.companyId).child(year).child(month)
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        self.report.removeAll()
                        if snapshot.childrenCount == 0{
                            self.loadIngReport = false
                        }else{
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                var theKey = String(rest.key)
                                let reportData = snapshot.childSnapshot(forPath: theKey!)
                                let parserReport = Report()
                                var monthString = month
                                if monthString.characters.count == 1{
                                    monthString = "0"+monthString
                                }
                                if theKey?.characters.count == 1{
                                    theKey = "0"+theKey!
                                }
                                parserReport.id = NSUUID().uuidString
                                parserReport.time = year+"-"+monthString+"-"+theKey!
                                parserReport.converToReport(snapshot: reportData)
                                self.report.append(parserReport)
                            }
                            self.loadIngReport = false
                        }
                    })
                }else{
                    self.loadIngReport = false
                }
            })
        }else{
            self.loadIngReport = false
        }
        print("end getReportFromOrderDayTotal() ============")
    }
    
    func getReportFromUserOrderDayTotal(year:String, month:String, userId:String){
        ref = Database.database().reference()
        print("start getReportFromUserOrderDayTotal() ============")
        loadIngReport = true
        if companyId != ""{
            self.ref?.child("user_order_day_total").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    let result =  self.ref?.child("user_order_day_total").child(self.companyId).child(userId).child(year).child(month)
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        self.report.removeAll()
                        if snapshot.childrenCount == 0{
                            self.loadIngReport = false
                        }else{
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                var theKey = String(rest.key)
                                let reportData = snapshot.childSnapshot(forPath: theKey!)
                                let parserReport = Report()
                                var monthString = month
                                if monthString.characters.count == 1{
                                    monthString = "0"+monthString
                                }
                                if theKey?.characters.count == 1{
                                    theKey = "0"+theKey!
                                }
                                parserReport.id = NSUUID().uuidString
                                parserReport.time = year+"-"+monthString+"-"+theKey!
                                parserReport.converToReport(snapshot: reportData)
                                self.report.append(parserReport)
                            }
                            self.loadIngReport = false
                        }
                    })
                }else{
                    self.loadIngReport = false
                }
            })
        }else{
            self.loadIngReport = false
        }
        print("end getReportFromUserOrderDayTotal() ============")
    }
    
    func getReportFromOrderMonthTotal(year:String){
        ref = Database.database().reference()
        print("start getReportFromOrderMonthTotal() ============")
        loadIngReport = true
        if companyId != ""{
            self.ref?.child("order_month_total").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    var result:DatabaseReference? = nil
                    if year != ""{
                        result = self.ref?.child("order_month_total").child(self.companyId).child(year)
                    }else{
                        result = self.ref?.child("order_month_total").child(self.companyId)
                    }
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        self.report.removeAll()
                        if snapshot.childrenCount == 0{
                            self.loadIngReport = false
                        }else{
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                if year != ""{
                                    var theKey = String(rest.key)
                                    let reportData = snapshot.childSnapshot(forPath: theKey!)
                                    let parserReport = Report()
                                    parserReport.id = NSUUID().uuidString
                                    if theKey?.characters.count == 1{
                                        theKey = "0"+theKey!
                                    }
                                    parserReport.time = year+"-"+theKey!
                                    parserReport.converToReport(snapshot: reportData)
                                    self.report.append(parserReport)
                                }else{
                                    let yearData = snapshot.childSnapshot(forPath: String(rest.key))
                                    let yearEnumerator = yearData.children
                                    var total = 0
                                    var discount = 0
                                    var totalCount = 0
                                    while let yearRest = yearEnumerator.nextObject() as? DataSnapshot {
                                        let reportData = yearData.childSnapshot(forPath: yearRest.key)
                                        let parserReport = Report()
                                        parserReport.converToReport(snapshot: reportData)
                                        total += parserReport.total
                                        discount += parserReport.discount
                                        totalCount += parserReport.totalCount
                                    }
                                    let parserReport = Report()
                                    parserReport.id = NSUUID().uuidString
                                    parserReport.time = String(rest.key)
                                    parserReport.total = total
                                    parserReport.discount = discount
                                    parserReport.totalCount = totalCount
                                    self.report.append(parserReport)
                                }
                            }
                            self.loadIngReport = false
                        }
                    })
                }else{
                    self.loadIngReport = false
                }
            })
        }else{
            self.loadIngReport = false
        }
        print("end getReportFromOrderMonthTotal() ============")
    }
    
    func getReportFromUserOrderMonthTotal(year:String, userId:String){
        ref = Database.database().reference()
        print("start getReportFromUserOrderMonthTotal() ============")
        loadIngReport = true
        if companyId != ""{
            self.ref?.child("user_order_month_total").observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    //有了  判斷是否 被刪除 or 停用！！
                    var result:DatabaseReference? = nil
                    if year != ""{
                        result = self.ref?.child("user_order_month_total").child(self.companyId).child(userId).child(year)
                    }else{
                        result = self.ref?.child("user_order_month_total").child(self.companyId).child(userId)
                    }
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        self.report.removeAll()
                        if snapshot.childrenCount == 0{
                            self.loadIngReport = false
                        }else{
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                if year != ""{
                                    var theKey = String(rest.key)
                                    let reportData = snapshot.childSnapshot(forPath: theKey!)
                                    let parserReport = Report()
                                    parserReport.id = NSUUID().uuidString
                                    if theKey?.characters.count == 1{
                                        theKey = "0"+theKey!
                                    }
                                    parserReport.time = year+"-"+theKey!
                                    parserReport.converToReport(snapshot: reportData)
                                    self.report.append(parserReport)
                                }else{
                                    let yearData = snapshot.childSnapshot(forPath: String(rest.key))
                                    let yearEnumerator = yearData.children
                                    var total = 0
                                    var discount = 0
                                    var totalCount = 0
                                    while let yearRest = yearEnumerator.nextObject() as? DataSnapshot {
                                        let reportData = yearData.childSnapshot(forPath: yearRest.key)
                                        let parserReport = Report()
                                        parserReport.converToReport(snapshot: reportData)
                                        total += parserReport.total
                                        discount += parserReport.discount
                                        totalCount += parserReport.totalCount
                                    }
                                    let parserReport = Report()
                                    parserReport.id = NSUUID().uuidString
                                    parserReport.time = String(rest.key)
                                    parserReport.total = total
                                    parserReport.discount = discount
                                    parserReport.totalCount = totalCount
                                    self.report.append(parserReport)
                                }
                            }
                            self.loadIngReport = false
                        }
                    })
                }else{
                    self.loadIngReport = false
                }
            })
        }else{
            self.loadIngReport = false
        }
        print("end getReportFromUserOrderMonthTotal() ============")
    }
    
    var loadIngAllProductCategory = false
    var allProductCategory = [ProductCategory]()
    func getAllProductCategory(parentId:String?){
        ref = Database.database().reference()
        print("start getAllProductCategory() ============")
        loadIngAllProductCategory = true
        if parentId != nil{
            loadIngProductCategorys = true
        }
        if companyId != ""{
            self.ref?.child("productCategorys").observe(DataEventType.value, with: {
                (snapshot) in
                if snapshot.hasChild(self.companyId){
                    let result =  self.ref?.child("productCategorys").child(self.companyId)
                    result?.observe(.value, with: {
                        (snapshot: DataSnapshot) in
                        self.allProductCategory.removeAll()
                        if snapshot.childrenCount == 0{
                            self.loadIngAllProductCategory = false
                        }else{
                            let enumerator = snapshot.children
                            while let rest = enumerator.nextObject() as? DataSnapshot {
                                let productCategoryData = snapshot.childSnapshot(forPath: String(rest.key))
                                let parserproductCategory = ProductCategory()
                                parserproductCategory.converToProductCategory(snapshot: productCategoryData)
                                self.allProductCategory.append(parserproductCategory)
                            }
                            
                            if parentId != nil{
                                self.getProductCategorys(parentId: parentId!)
                            }
                            
                            self.loadIngAllProductCategory = false
                        }
                    })
                }
            })
        }else{
            self.loadIngAllProductCategory = false
        }
        print("end getAllProductCategory() ============")
    }
    
    var loadIngMessage = false
    var messageReadHistorys = [MessageReadHistory]()
    func getMessage(){
        ref = Database.database().reference()
        print("start getMessage() ============")
        loadIngMessage = true
        let result =  self.ref?.child("message").child(self.companyId).child("product").queryOrdered(byChild: "careteDateTime")
        result?.observe(.value, with: {
            (snapshot: DataSnapshot) in
            self.messageReadHistorys.removeAll()
            if snapshot.childrenCount == 0{
                self.loadIngMessage = false
            }else{
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    let nowKey = String(rest.key)
                    let data = snapshot.childSnapshot(forPath: nowKey!)
                    let parserMessageReadHistory = MessageReadHistory()
                    parserMessageReadHistory.converToMessageReadHistory(snapshot: data)
                    parserMessageReadHistory.type = "product"
                    parserMessageReadHistory.type_id = nowKey!
                    self.messageReadHistorys.append(parserMessageReadHistory)
                    self.messageReadHistorys.reverse()
                }
                self.loadIngMessage = false
            }
        })
        print("end getMessage() ============")
    }
    
    var messageReadLastUpdateTime = [String:Date]()
    var loadIngMessageReadLastUpdateTime = false
    func getMessageReadLastUpdateTime(){
        ref = Database.database().reference()
        print("start getMessageReadLastUpdateTime() ============")
        loadIngMessageReadLastUpdateTime = true
        let result = self.ref?.child("message_read").child(companyId).child((currentUser?.uid)!)
        result?.observe(.value, with: {
            (snapshot: DataSnapshot) in
            self.messageReadLastUpdateTime.removeAll()
            if snapshot.childrenCount == 0{
                self.loadIngMessageReadLastUpdateTime = false
            }else{
                let dataFormate = DateFormatter()
                dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    var nowKey = ""
                    nowKey = String(rest.key)
                    switch nowKey {
                    case "product":
                        let lastUpdateTime = rest.value as! Int
                        let timestemp = lastUpdateTime / 1000
                        let lastUpdateDateTime = Date(timeIntervalSince1970: TimeInterval(timestemp))
                        dataFormate.timeZone = TimeZone.current
                        let p = dataFormate.string(from: lastUpdateDateTime)
                        self.messageReadLastUpdateTime["product"] = dataFormate.date(from: p)!
                        break;
                    default: break
                    }
                }
                self.loadIngMessageReadLastUpdateTime = false
            }
        })
        print("end getMessageReadLastUpdateTime() ============")
    }
    
    //    ref?.child("message_read").child(companyId).child("product").child((currentUser?.uid)!)
    
    //=================================================================================================
    var createUserIsRunning = false
    func createUser(user:User){
        ref = Database.database().reference()
        print(" ===== createUser() start ===== ")
        currentUser = nil
        createUserIsRunning = true
        ref?.child("users").child(user.uid).setValue(user.converToArray())
        currentUser = user
        createUserIsRunning = false
        print(" ===== createUser() end ===== ")
    }
    
    var createCompanyIsRunning = false
    func createCompany(user:User){
        ref = Database.database().reference()
        print(" ===== createCompany() start ===== ")
        createCompanyIsRunning = true
        
        let companyId = UUID.init().description
        let company = Company()
        company.ownerUid = user.uid
        ref?.child("companys").child(companyId).setValue(company.converToArray())
        
        user.companyId = companyId
        ref?.child("users").child(user.uid).setValue(user.converToArray())
        ref?.child("companyUsers").child(companyId).setValue([user.converToArray()])
        currentUser = user
        createCompanyIsRunning = false
        print(" ===== createCompany() end ===== ")
    }
    
    var updateUserIsRunning = false
    func updateUser(uid: String, companyId: String){
        updateUserIsRunning = true
        ref = Database.database().reference()
        var newCompanyUser = [[String:String]]()
        for item in companyUsers{
            if  item.uid == uid{
                ref?.child("users").child(uid).setValue(item.converToArray())
                newCompanyUser.append(item.converToArray())
            }else if  item.uid != ""{
                //避免 3 個假title 寫入
                newCompanyUser.append(item.converToArray())
            }
        }
        ref?.child("companyUsers").child(companyId).setValue(newCompanyUser)
        updateUserIsRunning = false
    }
    //---------------------------------------------------------------------------------------------
    func writeToken(token:String){
        if currentUser != nil{
            ref = Database.database().reference()
            ref?.child("token").child(self.companyId).child((currentUser?.uid)!).setValue(["token":token])
        }else{
            print("writeToken fail token = \(token)")
        }
    }
    
    var addProductCategoryIsRunning = false
    func addProductCategory(productCategory:ProductCategory){
        print("addProductCategory() start ======")
        addProductCategoryIsRunning = true
        ref = Database.database().reference()
        ref?.child("productCategorys").child(self.companyId).child(productCategory.id).setValue(productCategory.converToArray())
        
        let parent = productCategory.parent
        if(parent != nil && parent!.id != ""){
            parent!.childrenCategoryCount = parent!.childrenCategoryCount + 1
            self.ref?.child("productCategorys").child(self.companyId).child(parent!.id).setValue(parent!.converToArray())
        }
        
        addProductCategoryIsRunning = false
        print("addProductCategory() end ======")
    }
    
    var updateProductCategoryIsRunning = false
    func updateProductCategory(productCategory:ProductCategory){
        print("updateProductCategory() start ======")
        updateProductCategoryIsRunning = true
        ref = Database.database().reference()
        ref?.child("productCategorys").child(self.companyId).child(productCategory.id).setValue(productCategory.converToArray())
        updateProductCategoryIsRunning = false
        print("updateProductCategory() end ======")
    }
    
    var deleteProductCategoryIsRunning = false
    func deleteProductCategory(productCategory:ProductCategory){
        print("deleteProductCategory() start ======")
        deleteProductCategoryIsRunning = true
        ref = Database.database().reference()
        ref?.child("productCategorys").child(self.companyId).child(productCategory.id).removeValue()
        
        let parent = productCategory.parent
        if(parent != nil && parent!.id != ""){
            parent!.childrenCategoryCount = parent!.childrenCategoryCount - 1
            if(parent!.childrenCategoryCount < 0){
                parent!.childrenCategoryCount = 0
            }
            self.ref?.child("productCategorys").child(self.companyId).child(parent!.id).setValue(parent!.converToArray())
        }
        deleteProductCategoryIsRunning = false
        print("deleteProductCategory() end ======")
    }
    
    var updateProductIsRunning = false
    func updateProduct(product:Product, isAdd:Bool){
        print("updateProduct() start ======")
        updateProductIsRunning = true
        ref = Database.database().reference()
        product.companyId = self.companyId
        ref?.child("companyProduct").child(self.companyId).child(product.productCategoryId).child(product.id).setValue(product.converToArray())
        ref?.child("product").child(self.companyId).child(product.id).setValue(product.converToArray())
        if isAdd == true{
            let parent = product.parent
            if(parent != nil && parent!.id != ""){
                parent!.childrenProductCount = parent!.childrenProductCount + 1
                self.ref?.child("productCategorys").child(self.companyId).child(parent!.id).setValue(parent!.converToArray())
            }
        }
        updateProductIsRunning = false
        print("updateProduct() end ======")
    }
    
    var deleteProductIsRunning = false
    func deleteProduct(product:Product){
        print("deleteProduct() start ======")
        deleteProductIsRunning = true
        ref = Database.database().reference()
        ref?.child("companyProduct").child(self.companyId).child(product.productCategoryId).child(product.id).removeValue()
        if product.once_sold == true{
            ref?.child("product").child(self.companyId).child(product.id).setValue(product.converToArray())
        }else{
            ref?.child("product").child(self.companyId).child(product.id).removeValue()
        }
        let parent = product.parent
        if(parent != nil && parent!.id != ""){
            parent!.childrenProductCount = parent!.childrenProductCount - 1
            self.ref?.child("productCategorys").child(self.companyId).child(parent!.id).setValue(parent!.converToArray())
        }
        deleteProductIsRunning = false
        print("deleteProduct() end ======")
    }
    
    
    var replaceProductIsRunning = false
    func replaceProduct(target:Product, replaceTo: Product){
        print("replaceProduct() start ======")
        replaceProductIsRunning = true
        ref = Database.database().reference()
        // target
        ref?.child("companyProduct").child(self.companyId).child(target.productCategoryId).child(target.id).removeValue()
        ref?.child("product").child(self.companyId).child(target.id).setValue(target.converToArray())
        // replaceTo
        ref?.child("companyProduct").child(self.companyId).child(replaceTo.productCategoryId).child(replaceTo.id).setValue(replaceTo.converToArray())
        ref?.child("product").child(self.companyId).child(replaceTo.id).setValue(replaceTo.converToArray())
        replaceProductIsRunning = false
        print("replaceProduct() end ======")
    }
    
    var updateOrderIsRunning = false
    func updateOrder(order:Order){
        print("updateOrder() start ======")
        updateOrderIsRunning = true
        let now = Date()
        order.createDateTime = now
        let df =  DateFormatter()
        df.dateFormat = "yyyy"
        order.year = Int(df.string(from: now))!
        df.dateFormat = "MM"
        order.month = Int(df.string(from: now))!
        df.dateFormat = "dd"
        order.day = Int(df.string(from: now))!
        df.dateFormat = "HH:mm:ss:SSS"
        let index = df.string(from: now)
        order.id = index
        order.user_name = (currentUser?.name)!
        
        ref = Database.database().reference()
        ref?.child("order").child("alive").child(self.companyId)
            .child(String(order.year)).child(String(order.month)).child(String(order.day))
            .child(index).setValue(order.converToArray())
        updateOrderIsRunning = false
        print("updateOrder() end ======")
    }
    
    var deleteOrderIsRunning = false
    func deleteOrder(order:Order){
        print("deleteOrder() start ======")
        deleteOrderIsRunning = true
        ref = Database.database().reference()
        ref?.child("order").child("alive").child(self.companyId).child(String(order.year))
            .child(String(order.month)).child(String(order.day)).child(order.id)
            .removeValue()
        
        var deadOrderData =  order.converToArray()
        deadOrderData["operator_id"] = currentUser?.uid
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        deadOrderData["operator_time"] = timeStamp
        ref?.child("order").child("dead").child(self.companyId).child(String(order.year))
            .child(String(order.month)).child(String(order.day)).child(order.id)
            .setValue(deadOrderData)
        deleteOrderIsRunning = false
        print("deleteOrder() end ======")
    }
    
    var updateMessageReadIsRunning = false
    func updateMessageRead(type:String){
        print("updateMessageRead() start ======")
        updateMessageReadIsRunning = true
        ref = Database.database().reference()
        let timeInterval = NSDate().timeIntervalSince1970
        let lastUpdateTime = Int(timeInterval * 1000)
        ref?.child("message_read").child(companyId).child((currentUser?.uid)!).setValue([type:lastUpdateTime])
        print("updateMessageRead() end ======")
    }
    //==============================================================================================
    func realmWriteMessageReadHistory(messageReadHistory:MessageReadHistory){
        let realm = try! Realm()
        messageReadHistory.companyId = companyId
        messageReadHistory.uid = (currentUser?.uid)!
        try! realm.write {
            realm.add(messageReadHistory)
        }
    }
    
    func realmDeleteMessageReadHistory(messageReadHistory:MessageReadHistory){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(messageReadHistory)
        }
    }
    
    
}
