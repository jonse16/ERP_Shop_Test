//
//  OrderListViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/8.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderListViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    var timer:Timer!
    var dataService = DataService.sharedInstance()
    var message = Message.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    var styleColor = UIColor()
    let dataFormate = DateFormatter()
    
    var nowYear = 0
    var nowMonth = 0
    var nowDay = 0
    var yearData = [Int]()
    var monthData = [Int]()
    var dayData = [Int]()
    
    @IBOutlet var dateOtherView: UIView!
    @IBOutlet weak var dataPick: UIPickerView!
    var datePickData = DatePickData()
    
    @IBOutlet var orderItemOtherView: UIView!
    @IBOutlet weak var orderItem: UITableView!
    var orderItemTableViewController = OrderItemTableViewController()
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var tableTitle: UIStackView!
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    @IBAction func dataPickDown(_ sender: UIButton) {
        var pickMonth = ""
        pickMonth = String(nowMonth)
        if nowMonth < 10{
            pickMonth = "0"+pickMonth
        }
        
        var pickDay = ""
        pickDay = String(nowDay)
        if nowDay < 10{
            pickDay = "0"+pickDay
        }
        
        dateTextField.text = String(nowYear)+"-"+pickMonth+"-"+pickDay
        otherViewShow(show: false, identifierName: "date")
    }
    
    @IBAction func orderItemDown(_ sender: UIButton) {
        otherViewShow(show: false, identifierName: "orderItem")
    }
    
    func otherViewShow(show:Bool, identifierName:String){
        for target in view.constraints{
            if target.identifier == identifierName{
                if show == true{
                    target.constant = -1
                }else{
                    target.constant = view.frame.size.height * 0.7
                }
                break;
            }
        }
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        searchOrder()
    }
    
    func searchOrder(){
        openMask()
        let ymdArray = dateTextField.text?.components(separatedBy: "-")
        var ymdY = 0
        ymdY = Int((ymdArray?[0])!)!
        let year = String(describing: ymdY)
        var ymdM = 0
        ymdM = Int((ymdArray?[1])!)!
        let month = String(describing: ymdM)
        var ymdD = 0
        ymdD = Int((ymdArray?[2])!)!
        let day = String(describing: ymdD)
        
        dataService.getOrder(year: year, month: month, day: day)
        checkGetOrderFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkGetOrderFinish),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    var checkGetOrderFinishCount = 0
    func checkGetOrderFinish(){
        if checkGetOrderFinishCount == 20{
            timer.invalidate()
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.loadIngOrder == false{
                timer.invalidate()
                closeMask()
                if dataService.order.count == 0{
                    message.popAlert(title: "結果通知", message: "目前無資料", uiViewController: self)
                }
                orderTableView.reloadData()
            }
        }
        checkGetOrderFinishCount += 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dataPick.reloadAllComponents()
        let now = Date()
        let calendar = Calendar.current
        let y = calendar.component(.year, from: now)
        dataPick.selectRow(y-nowYear, inComponent: 0, animated: true)
        dataPick.selectRow(nowMonth-1, inComponent: 1, animated: true)
        dataPick.selectRow(nowDay-1, inComponent: 2, animated: true)
        otherViewShow(show: true, identifierName: "date")
        textField.resignFirstResponder()
    }
    //------------------------------------------------------------------------------------------------------------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var value = 0
        if component == 0{
            value = yearData.count
        }
        if component == 1{
            value = monthData.count
        }
        if component == 2{
            value = dayData.count
        }
        
        return value
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var value = ""
        
        if component == 0{
            value = String(yearData[row])
        }
        if component == 1{
            value = String(monthData[row])
        }
        if component == 2{
            value = String(dayData[row])
        }
        return value
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0,1:
            if component == 0{
                nowYear = yearData[row]
            }else{
                nowMonth = monthData[row]
            }
            let newDayDataCount = datePickData.getDayDataCount(nowMonth: nowMonth, nowYear: nowYear)
            if  newDayDataCount != dayData.count{
                datePickData.createDayData(max: newDayDataCount, dayData: &dayData)
                pickerView.reloadComponent(2)
                if nowDay > newDayDataCount{
                    nowDay = newDayDataCount
                }
                dataPick.selectRow(nowDay-1, inComponent: 2, animated: true)
                
            }
        case 2:
            nowDay = dayData[row]
        default:
            break;
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataService.order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? OrderListTableViewCell
        let order = dataService.order[indexPath.row];
        dataFormate.dateFormat = "HH:mm:ss"
        cell?.time.text = dataFormate.string(from: order.createDateTime)
        var discount = ""
        discount = String(order.discount)
        cell?.discount.text = discount
        var total = ""
        total = String(order.total)
        cell?.total.text = total
        cell?.name.text = order.user_name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var result = [UITableViewRowAction]()
        let row = indexPath.row
        let delete  = UITableViewRowAction(style: .normal, title: "刪除") { (rowAction, indexPath) in
            let alert =  UIAlertController(title: "刪除確認", message: "確認刪除?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (alert: UIAlertAction!) in
                self.openMask()
                self.dataService.deleteOrder(order: self.dataService.order[indexPath.row])
                self.checkDeleteOrderFinishCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                  target: self,
                                                  selector: #selector(self.checkDeleteOrderFinish),
                                                  userInfo: nil,
                                                  repeats: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor(red: 204/255, green: 64/255, blue: 66/255, alpha: 1.0)
        result.append(delete)
        let edit = UITableViewRowAction(style: .normal, title: "明細") { (rowAction, indexPath) in
            self.toShowOrderItem(index: row)
        }
        edit.backgroundColor = UIColor(red: 88/255, green: 178/255, blue: 220/255, alpha: 1.0)
        result.append(edit)
        
        return result
    }
    
    var checkDeleteOrderFinishCount = 0
    
    func checkDeleteOrderFinish(){
        if checkDeleteOrderFinishCount == 20{
            timer.invalidate()
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.deleteOrderIsRunning == false{
                timer.invalidate()
                // prepare reload data
                searchOrder()
            }
        }
        checkDeleteOrderFinishCount += 1
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toShowOrderItem(index: indexPath.row)
    }
    
    func toShowOrderItem(index: Int){
        orderItemTableViewController.orderItems = dataService.order[index].items
        orderItem.reloadData()
        otherViewShow(show: true, identifierName: "orderItem")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maskActive.startAnimating()
        closeMask()
        
        styleColor = viewSetting.styleColor
        search.backgroundColor = styleColor
        search.setTitleColor(UIColor.white, for: .normal)
        search.layer.cornerRadius = 5
        for item in tableTitle.arrangedSubviews{
            if let label = item as? UILabel{
                label.textColor = UIColor.white
                label.backgroundColor = styleColor
            }
        }
        
        let now = Date()
        let calendar = Calendar.current
        nowYear = calendar.component(.year, from: now)
        nowMonth = calendar.component(.month, from: now)
        nowDay = calendar.component(.day, from: now)
        
        dateTextField.delegate = self
        let df =  DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        dateTextField.text = df.string(from: now)
        
        for index in 0...99{
            yearData.append(nowYear-index)
        }
        
        for index in 1...12{
            monthData.append(index)
        }
        
        datePickData.createDayData(max: datePickData.getDayDataCount(nowMonth: nowMonth, nowYear: nowYear), dayData: &dayData)
        
        
        orderItem.delegate = orderItemTableViewController
        orderItem.dataSource = orderItemTableViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(dateOtherView)
        dateOtherView.translatesAutoresizingMaskIntoConstraints = false
        dateOtherView.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.7).isActive = true
        dateOtherView.heightAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        dateOtherView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        dateOtherView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0).isActive = true
        let date = dateOtherView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.size.height * 0.7)
        date.identifier = "date"
        date.isActive = true
        
        view.addSubview(orderItemOtherView)
        orderItemOtherView.translatesAutoresizingMaskIntoConstraints = false
        orderItemOtherView.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.7).isActive = true
        orderItemOtherView.heightAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        orderItemOtherView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        orderItemOtherView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0).isActive = true
        let orderItem = orderItemOtherView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.size.height * 0.7)
        orderItem.identifier = "orderItem"
        orderItem.isActive = true
        super.viewWillAppear(animated)
    }
}
