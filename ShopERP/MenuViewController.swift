//
//  MenuViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/19.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var allFunction = ["結帳","訂單列表","商品","訊息","業績","報表","組織","登出"]
    
    let color = [UIColor(red: 232/255, green: 122/255, blue: 144/255, alpha: 1.0),
                 UIColor(red: 180/255, green: 129/255, blue: 187/255, alpha: 1.0),
                 UIColor(red: 250/255, green: 214/255, blue: 137/255, alpha: 1.0),
                 UIColor(red: 191/255, green: 103/255, blue: 102/255, alpha: 1.0),
                 UIColor(red: 180/255, green: 165/255, blue: 130/255, alpha: 1.0),
                 UIColor(red: 102/255, green: 186/255, blue: 183/255, alpha: 1.0),
                 UIColor(red: 88/255, green: 178/255, blue: 220/255, alpha: 1.0),
                 UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0)]
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    let dataService = DataService.sharedInstance()
    let message = Message.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    
    var timer:Timer!
    var messageTimer:Timer!
    
    var performanceType = ""
    
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("allFunction.count ==================\(allFunction.count)")
        return allFunction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MenuCollcetionCellController
        let indexPathRow = indexPath.row
        let cellButton = cell!.button
        cellButton?.setTitle(allFunction[indexPathRow], for: .normal)
        cellButton?.setTitleColor(UIColor.white, for: .normal)
        cellButton?.setTitleColor(UIColor.black, for: .highlighted)
        cellButton?.layer.cornerRadius = 5.0
        cellButton?.layer.masksToBounds = true
        cellButton?.backgroundColor = color[indexPathRow]
        cellButton?.tag = indexPathRow
        
        cellButton?.addTarget(self, action: #selector(MenuViewController.buttonTouchUpInside(sender:)), for: .touchUpInside)
        return cell!;
    }
    
    func buttonTouchUpInside(sender: UIButton){
        openMask()
        if !dataService.isValidInternet(){
            closeMask()
            message.popAlert(title: "網路錯誤", message: "請檢查網路連線", uiViewController: self)
            return;
        }
        
        viewSetting.styleColor = sender.backgroundColor!
        viewSetting.titleBarText = (sender.titleLabel?.text)!
        viewSetting.titleHomeButtonIsHidden = false
        
        switch sender.tag {
        case 0:
            goToOtherPage(segueIdentifier: "goToOrder")
            
        case 1:
            goToOtherPage(segueIdentifier: "goToOrderList")
        case 2:
            viewSetting.titleBarText = "商品類別"
            if dataService.loadIngProductCategorys == true{
                self.checkGetProductCategorysFinishCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                  target: self,
                                                  selector: #selector(self.checkGetProductCategorysFinish),
                                                  userInfo: nil,
                                                  repeats: true)
            }else{
                closeMask()
                goToOtherPage(segueIdentifier: "goToProductCatagory")
            }
        case 3:
            goToOtherPage(segueIdentifier: "goToMessage")
        case 4:
            closeMask()
            performanceType = "self"
            goToOtherPage(segueIdentifier: "goToPerformance")
            //            let userInfo = ["messageId":"123456"]
        //            message.sendNotification(title: "go", subtitle: "subtitle", body: "go to order", categoryIdentifier: "message", userInfo: userInfo)
        case 5:
            closeMask()
            performanceType = "company"
            goToOtherPage(segueIdentifier: "goToPerformance")
        case 6:
            if dataService.loadIngCompanyAllUser == true{
                self.checkGetCompanyAllUserFinishCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                  target: self,
                                                  selector: #selector(self.checkGetCompanyAllUserFinish),
                                                  userInfo: nil,
                                                  repeats: true)
            }else{
                closeMask()
                goToOtherPage(segueIdentifier: "goToCompany")
            }
        case 7:
            let alert =  UIAlertController(title: "登出確認", message: "您確定要登岀嗎？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action) in
                do{
                    self.viewSetting.setDefault()
                    try Auth.auth().signOut()
                }catch{
                    print("Auth.auth().signOut() error = \(error.localizedDescription)")
                }
                self.goToOtherPage(segueIdentifier: "goToLogin")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
                (action) in
                self.closeMask()
            }))
            present(alert, animated: true, completion: nil)
        default:
            break;
        }
    }
    
    var checkGetProductCategorysFinishCount = 0
    func checkGetProductCategorysFinish(){
        if checkGetProductCategorysFinishCount == 20{
            print("checkGetProductCategorysFinishCount == 20")
            timer.invalidate()
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.loadIngProductCategorys == false{
                timer.invalidate()
                closeMask()
                goToOtherPage(segueIdentifier: "goToProductCatagory")
            }
        }
        checkGetProductCategorysFinishCount += 1
    }
    
    var checkGetCompanyAllUserFinishCount = 0
    func checkGetCompanyAllUserFinish(){
        if checkGetCompanyAllUserFinishCount == 20{
            timer.invalidate()
            print("checkGetCompanyAllUserFinishCount == 20")
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.loadIngCompanyAllUser == false{
                timer.invalidate()
                closeMask()
                goToOtherPage(segueIdentifier: "goToCompany")
            }
        }
        checkGetCompanyAllUserFinishCount += 1
    }
    
    func goToOtherPage(segueIdentifier:String){
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maskActive.startAnimating()
        //商品
        dataService.getAllProductCategory(parentId: "")
        //組織
        dataService.getCompanyAllUser()
        // Do any additional setup after loading the view.
        dataService.getMessage()
        dataService.getMessageReadLastUpdateTime()
        
        self.checkGetMessageInfoFinishCount = 0
        self.messageTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                                 target: self,
                                                 selector: #selector(self.checkGetMessageInfoFinish),
                                                 userInfo: nil,
                                                 repeats: true)
    }
    
    var checkGetMessageInfoFinishCount = 0
    func checkGetMessageInfoFinish(){
        if checkGetMessageInfoFinishCount == 20{
            messageTimer.invalidate()
            print("checkGetMessageInfoFinishCount == 20")
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.loadIngMessage == false && dataService.loadIngMessageReadLastUpdateTime == false {
                messageTimer.invalidate()
                let messageReadHistorys = dataService.messageReadHistorys
                if messageReadHistorys.isEmpty == false{
                    let dataFormate = DateFormatter()
                    dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    var count = 0
                    let messageReadLastUpdateTime = dataService.messageReadLastUpdateTime
                    for item in messageReadHistorys{
                        if let last = messageReadLastUpdateTime[item.type]{                            
                            if item.createDateTime > last{
                                count = count+1;
                            }
                        }else{
                            count = count+1;
                        }
                    }
                    
                    if count > 0{
                        var newTitle = ""
                        if count > 100{
                            newTitle = self.allFunction[3]+"("+String(count)+"+)"
                        }else{
                            newTitle = self.allFunction[3]+"("+String(count)+")"
                        }
                        
                        var index = 0
                        //順序是相反的！！
                        for item in collectionView.visibleCells{
                            if index == 7{
                                let cell = item as? MenuCollcetionCellController
                                cell!.button.setTitle(newTitle, for: .normal)
                            }
                            index += 1;
                        }
                    }
                }
            }
        }
        checkGetMessageInfoFinishCount += 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPerformance"{
            if let dvc = segue.destination as? PerformanceViewController{
                dvc.type = performanceType
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
