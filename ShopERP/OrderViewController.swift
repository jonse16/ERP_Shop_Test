//
//  OrderViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/18.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var timer:Timer!
    var dataService = DataService.sharedInstance()
    var message = Message.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    var styleColor = UIColor()
    
    @IBOutlet weak var changeTotal: UIButton!
    @IBOutlet weak var paySuccess: UIButton!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var toi = TempOrderItems.sharedInstance()
    
    var editOrder = TempOrderItems.sharedInstance().order
    
    var totalInt = 0
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editOrder.items.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? OrderTableViewCell
        let row = indexPath.row
        cell?.less.tag = row
        if row == editOrder.items.count{
            cell?.name.text = ""
            cell?.count.text = ""
            cell?.total.text = ""
            cell?.less.addTarget(self, action: #selector(OrderViewController.addOrderItem(sender:)), for: .touchUpInside)
            cell?.less.setTitle("+", for: .normal)
            cell?.less.setTitleColor(styleColor, for: .normal)
            cell?.less.isEnabled = true
        }else{
            let orderItem = editOrder.items[row]
            cell?.name.text = orderItem.product?.name
            cell?.count.text = "X \(orderItem.count)"
            cell?.total.text = String((orderItem.count) * (orderItem.product?.list_price)!)
            
            cell?.less.setTitle("", for: .normal)
            cell?.less.isEnabled = false
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var result = [UITableViewRowAction]()
        let row = indexPath.row
        if row != editOrder.items.count{
            let oldCount = self.editOrder.items[row].count
            let oldTotal = self.editOrder.items[row].total
            
            let delete  = UITableViewRowAction(style: .normal, title: "移除品項") { (rowAction, indexPath) in
                let row = indexPath.row
                let alert =  UIAlertController(title: "移除確認", message: "確定移除此品項？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (alert: UIAlertAction!) in
                    self.editOrder.items.remove(at: row)
                    self.reCountOrder()
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            delete.backgroundColor = UIColor(red: 204/255, green: 64/255, blue: 66/255, alpha: 1.0)
            result.append(delete)
            
            
            let changeCount = UITableViewRowAction(style: .normal, title: "修改數量") { (rowAction, indexPath) in
                let alert = UIAlertController(title: "修改數量", message: nil, preferredStyle: .alert)
                alert.addTextField(configurationHandler: {
                    (textfield) in
                    textfield.placeholder = "請輸入數量"
                    textfield.text = String(describing: oldCount)
                    textfield.keyboardType = UIKeyboardType.numberPad
                })
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action) in
                    if let inputText = alert.textFields?[0].text{
                        if inputText != ""{
                            let newCount = Int(inputText)
                            if oldCount != newCount{
                                if newCount! > 0{
                                    self.editOrder.items[row].count = newCount!
                                    self.editOrder.items[row].total = (oldTotal/oldCount)*newCount!
                                    
                                    self.reCountOrder()
                                    
                                    if let cell = tableView.cellForRow(at: indexPath) as? OrderTableViewCell{
                                        let orderItem = self.editOrder.items[row]
                                        cell.name.text = orderItem.product?.name
                                        cell.count.text = "X \(orderItem.count)"
                                        cell.total.text = String((orderItem.count) * (orderItem.product?.list_price)!)
                                    }
                                }else{
                                    self.message.popAlert(title: "參數有誤", message: "請使用移除品項功能", uiViewController: self)
                                }
                            }
                        }else{
                            self.message.popAlert(title: "參數有誤", message: "數量不可為空值", uiViewController: self)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            changeCount.backgroundColor = UIColor(red: 88/255, green: 178/255, blue: 220/255, alpha: 1.0)
            result.append(changeCount)
        }
        return result
    }
    
    func addOrderItem(sender: UIButton){
        let alert =  UIAlertController(title: "新增品項", message: "請選擇方式", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "條碼掃描", style: .default, handler: {
            (alert: UIAlertAction!) in
            self.goToOtherPage(segueIdentifier: "goToCodeScan")
        }))
        //        alert.addAction(UIAlertAction(title: "商品列表", style: .default, handler: {
        //            (alert: UIAlertAction!) in
        //
        //        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func goToOtherPage(segueIdentifier:String){
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    func reCountOrder(){
        var totalCount = 0
        for item in (editOrder.items){
            totalCount += item.total
        }
        
        if editOrder.items.count > 0{
            changeTotal.isEnabled = true
            changeTotal.isHidden = false
            paySuccess.isEnabled = true
            paySuccess.isHidden = false
        }else{
            changeTotal.isEnabled = false
            changeTotal.isHidden = true
            paySuccess.isEnabled = false
            paySuccess.isHidden = true
        }
        
        editOrder.total = totalCount
        editOrder.totalCount = totalCount
        editOrder.discount = 0
        discount.text = "折扣金額 : 0"
        total.text = "總金額: \(totalCount)"
    }
    
    
    @IBAction func changeTotal(_ sender: UIButton) {
        let alert = UIAlertController(title: "變更總金額(折扣)", message: "請輸入總金額", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "請輸入總金額"
            textfield.text = String(describing: self.editOrder.total)
            textfield.keyboardType = UIKeyboardType.numberPad
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            if let inputText = alert.textFields?[0].text{
                if inputText != ""{
                    var newTotal = 0
                    newTotal = Int(inputText)!
                    
                    //價格太低
                    var cost = 0
                    for item in self.editOrder.items{
                        cost +=  ((item.product?.price)! * item.count)
                    }
                    
                    if newTotal < cost{
                        self.message.popAlert(title: "參數有誤", message: "總金額為非法數字", uiViewController: self)
                    }else if newTotal == self.editOrder.totalCount{
                    }else{
                        self.editOrder.total = newTotal
                        let discount = self.editOrder.totalCount - self.editOrder.total
                        self.editOrder.discount = discount
                        self.discount.text = "折扣金額 : \(discount)"
                        self.discount.textColor = UIColor.red
                        self.total.text = "總金額 : \(newTotal)"
                    }
                }else{
                    self.message.popAlert(title: "參數有誤", message: "總金額不可為空值", uiViewController: self)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func paySuccess(_ sender: UIButton) {
        let alert = UIAlertController(title: "結帳確認", message: "確定結帳？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            self.editOrder.status = 1
            self.dataService.updateOrder(order: self.editOrder)
            self.updateOrderFinishCount = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                              target: self,
                                              selector: #selector(self.updateOrderFinish),
                                              userInfo: nil,
                                              repeats: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var updateOrderFinishCount = 0
    func updateOrderFinish(){
        if updateOrderFinishCount == 20{
            timer.invalidate()
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.updateProductIsRunning == false{
                timer.invalidate()
                editOrder = Order()
                let currentUser = dataService.currentUser!
                toi.orderIni(currentUser: currentUser)
                let alert = UIAlertController(title: "交易完成", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                tableView.reloadData()
                ini()
            }
        }
        updateOrderFinishCount += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor
        let currentUser = dataService.currentUser!
        if editOrder.id == ""{
            toi.orderIni(currentUser: currentUser)
        }
        changeTotal.setTitleColor(styleColor, for: .normal)
        paySuccess.setTitleColor(styleColor, for: .normal)
        ini()
    }
    
    func ini(){
        if editOrder.items.count > 0{
            changeTotal.isEnabled = true
            changeTotal.isHidden = false
            paySuccess.isEnabled = true
            paySuccess.isHidden = false
        }else{
            changeTotal.isEnabled = false
            changeTotal.isHidden = true
            paySuccess.isEnabled = false
            paySuccess.isHidden = true
        }
        
        discount.text = "折扣金額 : 0"
        let stringTotal = String(describing: editOrder.total)
        total.text = "總金額 : \(stringTotal)"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}
