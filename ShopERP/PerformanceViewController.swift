//
//  PerformanceViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/27.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class PerformanceViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    var styleColor = UIColor()
    let dataService = DataService.sharedInstance()
    let message = Message.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    var timer:Timer!
    var type = ""
    var nowYear = 0
    var nowMonth = 0
    var nowDay = 0
    var nowUser = User()
    @IBOutlet var dataPickView: UIView!
    @IBOutlet weak var dataPick: UIPickerView!
    var searchUserId = ""
    var dataPickType = ""
    var users = [User]()
    var yearData = [Int]()
    var monthData = [Int]()
    var dayData = [Int]()
    @IBOutlet weak var segmented: UISegmentedControl!
    var selectedSegmentIndex = 3
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableTitle: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    @IBAction func dataPickDown(_ sender: UIButton) {
        if dataPickType == "date"{
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
        }
        
        if dataPickType == "user"{
            userTextField.text = nowUser.name
        }
        
        dataPickViewShow(show: false)
    }
    
    func dataPickViewShow(show:Bool){
        for target in view.constraints{
            if target.identifier == "point"{
                if show == true{
                    target.constant = -1
                }else{
                    target.constant = view.frame.size.height * 0.5
                }
                break;
            }
        }
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func segmentedValueChange(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.placeholder == "請選擇日期"{
            dataPickType = "date"
            dataPick.reloadAllComponents()
            let now = Date()
            let calendar = Calendar.current
            let y = calendar.component(.year, from: now)
            dataPick.selectRow(y-nowYear, inComponent: 0, animated: true)
            dataPick.selectRow(nowMonth-1, inComponent: 1, animated: true)
            dataPick.selectRow(nowDay-1, inComponent: 2, animated: true)
        }else if textField.placeholder == "請選擇員工"{
            dataPickType = "user"
            dataPick.reloadAllComponents()
            var row = 0
            for index in 0...(users.count-1){
                if users[index].uid == nowUser.uid{
                    row = index
                    break
                }
            }
            dataPick.selectRow(row, inComponent: 0, animated: true)
        }
        dataPickViewShow(show: true)
        textField.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if dataPickType == "date"{
            return 3
        }
        if dataPickType == "user"{
            return 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var value = 0
        if dataPickType == "date"{
            if component == 0{
                value = yearData.count
            }
            if component == 1{
                value = monthData.count
            }
            if component == 2{
                value = dayData.count
            }
        }
        if dataPickType == "user"{
            value = users.count
        }
        return value
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var value = ""
        if dataPickType == "date"{
            if component == 0{
                value = String(yearData[row])
            }
            if component == 1{
                value = String(monthData[row])
            }
            if component == 2{
                value = String(dayData[row])
            }
        }
        if dataPickType == "user"{
            value = users[row].name
        }
        return value
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dataPickType == "date"{
            switch component {
            case 0,1:
                if component == 0{
                    nowYear = yearData[row]
                }else{
                    nowMonth = monthData[row]
                }
                let newDayDataCount = getDayDataCount()
                if  newDayDataCount != dayData.count{
                    createDayData(max: newDayDataCount)
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
        if dataPickType == "user"{
            searchUserId = users[row].uid
            nowUser = users[row]
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        search()
    }
    
    func search(){
        openMask()
        let ymdArray = dateTextField.text?.components(separatedBy: "-")
        var ymdY = 0
        ymdY = Int((ymdArray?[0])!)!
        var year = String(describing: ymdY)
        var ymdM = 0
        ymdM = Int((ymdArray?[1])!)!
        let month = String(describing: ymdM)
        var ymdD = 0
        ymdD = Int((ymdArray?[2])!)!
        let day = String(describing: ymdD)

        var type = ""
        switch selectedSegmentIndex {
        case 0:
            type = "all"
            year = ""
        case 1:
            type = "year"
        case 2:
            type = "month"
        case 3:
            type = "day"
        default:
            type = ""
        }
        
        dataService.getReport(type: type, year: year, month: month, day: day, userId: searchUserId)
        checkGetReportFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkGetReportFinish),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    var checkGetReportFinishCount = 0
    func checkGetReportFinish(){
        if checkGetReportFinishCount == 20{
            timer.invalidate()
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ", uiViewController: self)
            return;
        }else {
            if dataService.loadIngReport == false{
                timer.invalidate()
                closeMask()
                if dataService.report.count == 0{
                    message.popAlert(title: "結果通知", message: "目前無資料", uiViewController: self)
                }
                tableView.reloadData()
            }
        }
        checkGetReportFinishCount += 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataService.report.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? PerformanceTableViewCell
        cell?.time.text = dataService.report[indexPath.row].time
        cell?.discount.text = String(dataService.report[indexPath.row].discount)
        cell?.total.text = String(dataService.report[indexPath.row].total)
        return cell!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maskActive.startAnimating()
        closeMask()

        styleColor = viewSetting.styleColor
        dataService.report.removeAll()
        
        searchButton.backgroundColor = styleColor
        searchButton.layer.cornerRadius = 5
        tableTitle.backgroundColor = styleColor
        
        let now = Date()
        let calendar = Calendar.current
        nowYear = calendar.component(.year, from: now)
        nowMonth = calendar.component(.month, from: now)
        nowDay = calendar.component(.day, from: now)
        
        dateTextField.delegate = self
        userTextField.delegate = self
        let df =  DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        dateTextField.text = df.string(from: now)
        
        segmented.setTitle("總報表", forSegmentAt: 0)
        segmented.setTitle("年", forSegmentAt: 1)
        segmented.setTitle("月", forSegmentAt: 2)
        segmented.setTitle("日", forSegmentAt: 3)
        segmented.tintColor = styleColor
        segmented.selectedSegmentIndex = 3
        
        dataPick.delegate = self
        dataPick.dataSource = self
        
        if type == "self"{
            userTextField.isHidden = true
            userTextField.isEnabled = false
            searchUserId = (dataService.currentUser?.uid)!
        }else if type == "company"{
            let defaultUser = User()
            defaultUser.name = "不限員工"
            defaultUser.uid = ""
            users.append(defaultUser)
            for item in dataService.companyUsers{
                if item.uid != ""{
                    users.append(item)
                }
            }
            if users.count > 0{
                searchUserId = users[0].uid
                nowUser = users[0]
            }
            
            userTextField.text = "不限員工"
        }
        
        for index in 0...99{
            yearData.append(nowYear-index)
        }
        
        for index in 1...12{
            monthData.append(index)
        }
        createDayData(max: getDayDataCount())
    }
    
    func getDayDataCount() -> Int{
        switch nowMonth {
        case 1,3,5,7,8,10,12:
            return 31
        case 4,6,9,11:
            return 30
        case 2:
            if nowYear%400 == 0 || (nowYear%4 == 0 && nowYear%100 != 0){
                return 29
            }else{
                return 28
            }
        default:
            return 0
        }
    }
    
    func createDayData(max:Int){
        dayData.removeAll()
        for index in 1...max{
            dayData.append(index)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(dataPickView)
        dataPickView.translatesAutoresizingMaskIntoConstraints = false
        dataPickView.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.5).isActive = true
        dataPickView.heightAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        dataPickView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        dataPickView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0).isActive = true
        
        let point = dataPickView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.size.height * 0.5)
        
        point.identifier = "point"
        point.isActive = true
        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
