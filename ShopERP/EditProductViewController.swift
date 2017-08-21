//
//  EditProductViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/5.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class EditProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    var dataService = DataService.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    var styleColor = UIColor()
    var timer:Timer!
    var categoryTree = [ProductCategory]()
    var labelArray = ["名稱","條碼","成本價","牌價","庫存數量","庫存提醒","上架"]
    var name = UITextField()
    var barcode = UITextField()
    var price = UITextField()
    var list_price = UITextField()
    var stock = UISwitch()
    var stock_count = UITextField()
    var reminder_stockUILabel = UILabel()
    var reminder_stock = UISwitch()
    var reminder_stock_count = UITextField()
    var enable = UISwitch()
    var oldCGPoint:CGPoint? = nil
    var nowUITextField:UITextField? = nil
    var editProduct = Product()
    var oldPrice = 0
    var oldList_price = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var maskView: UIView!
    
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nowUITextField != nil{
            nowUITextField?.resignFirstResponder()
            tableView.setContentOffset(oldCGPoint!, animated: true)
            nowUITextField = nil
        }
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nowUITextField = textField
        oldCGPoint = tableView.accessibilityActivationPoint
        let indexPath = IndexPath(row: textField.tag, section: 0)
        let cellRectInView = tableView.convert(tableView.rectForRow(at: indexPath), to: self.view)
        let nowY = Int(cellRectInView.size.height) * textField.tag
        tableView.setContentOffset(CGPoint(x: 0, y: nowY), animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (labelArray.count+1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? EditProductTableViewCell
        let index = indexPath.row
        if index != labelArray.count{
            let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            //設定是否庫存商品不可修改
            if editProduct.id != "" && index == 4{
                label.textColor = UIColor.gray
            }
            label.text = labelArray[index]
            
            label.textAlignment = NSTextAlignment.right
            
            let width = 170
            
            
            switch index {
            case 0:
                name.frame = CGRect(x: 130, y: 0, width: width, height: 30)
                name.keyboardType = UIKeyboardType.default
                name.borderStyle = UITextBorderStyle.roundedRect
                name.delegate = self
                name.tag = index
                cell?.content.addSubview(name)
            case 1:
                barcode.frame = CGRect(x: 130, y: 0, width: width, height: 30)
                barcode.keyboardType = UIKeyboardType.numberPad
                barcode.borderStyle = UITextBorderStyle.roundedRect
                barcode.delegate = self
                barcode.tag = index
                cell?.content.addSubview(barcode)
            case 2:
                price.frame = CGRect(x: 130, y: 0, width: width, height: 30)
                price.keyboardType = UIKeyboardType.numberPad
                price.borderStyle = UITextBorderStyle.roundedRect
                price.delegate = self
                price.tag = index
                cell?.content.addSubview(price)
            case 3:
                list_price.frame = CGRect(x: 130, y: 0, width: width, height: 30)
                list_price.keyboardType = UIKeyboardType.numberPad
                list_price.borderStyle = UITextBorderStyle.roundedRect
                list_price.delegate = self
                list_price.tag = index
                cell?.content.addSubview(list_price)
            case 4:
                stock.frame = CGRect(x: 130, y: 0, width: 51, height: 30)
                stock.addTarget(self, action: #selector(stockSwitchChanged), for: UIControlEvents.valueChanged)
                cell?.content.addSubview(stock)
                
                if editProduct.id != ""{
                    if editProduct.stock == true{
                        stock_count.isHidden = false
                    }else{
                        stock_count.isHidden = true
                    }
                }
                
                stock_count.frame = CGRect(x: 211, y: 0, width: 89, height: 30)
                stock_count.keyboardType = UIKeyboardType.numberPad
                stock_count.borderStyle = UITextBorderStyle.roundedRect
                stock_count.delegate = self
                stock_count.tag = index
                cell?.content.addSubview(stock_count)
                
                
            case 5:
                reminder_stockUILabel = label
                
                reminder_stock.frame = CGRect(x: 130, y: 0, width: 51, height: 30)
                reminder_stock.addTarget(self, action: #selector(reminderStockSwitchChanged), for: UIControlEvents.valueChanged)
                cell?.content.addSubview(reminder_stock)
                
                if editProduct.id != ""{
                    if editProduct.reminder_stock == true{
                        reminder_stock_count.isHidden = false
                    }else{
                        reminder_stock_count.isHidden = true
                    }
                }
                
                reminder_stock_count.frame = CGRect(x: 211, y: 0, width: 89, height: 30)
                reminder_stock_count.keyboardType = UIKeyboardType.numberPad
                reminder_stock_count.borderStyle = UITextBorderStyle.roundedRect
                reminder_stock_count.delegate = self
                reminder_stock_count.tag = index
                cell?.content.addSubview(reminder_stock_count)
                
                stockSwitchChanged()
                reminderStockSwitchChanged()
            case 6:
                enable.frame = CGRect(x: 130, y: 0, width: 51, height: 30)
                cell?.content.addSubview(enable)
            default:
                print("default")
            }
            
            cell?.content.addSubview(label)
        }else{
            let button = UIButton(type: UIButtonType.system)
            button.frame = CGRect(x: 100, y: 0, width: 100, height: 30)
            button.setTitle("儲存", for: .normal)
            button.addTarget(self, action: #selector(buttonSubmit), for: UIControlEvents.touchUpInside)
            button.setTitleColor(styleColor, for: .normal)
            cell?.content.addSubview(button)
        }
        return cell!;
    }
    
    func stockSwitchChanged(){
        if stock.isOn == true{
            stock_count.isHidden = false
            
            reminder_stockUILabel.textColor = UIColor.black
            reminder_stock.isEnabled = true
            reminder_stock_count.isUserInteractionEnabled = true
        }else{
            stock_count.isHidden = true
            stock_count.text = "0"
            
            reminder_stockUILabel.textColor = UIColor.gray
            reminder_stock.isEnabled = false
            reminder_stock.isOn = false
            reminder_stock_count.isUserInteractionEnabled = false
            reminderStockSwitchChanged()
        }
    }
    
    func reminderStockSwitchChanged(){
        if reminder_stock.isOn == true{
            reminder_stock_count.isHidden = false
        }else{
            reminder_stock_count.isHidden = true
            reminder_stock_count.text = "0"
        }
    }
    
    func buttonSubmit(){
        let alert =  UIAlertController(title: "", message: "確定儲存？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
            self.openMask()
            if !self.dataService.isValidInternet(){
                self.popAlert(title: "網路錯誤", message: "請檢查網路連線")
                self.closeMask()
                return;
            }
            
            //validate
            let nameValue = self.name.text
            let barcodeValue = self.barcode.text
            let priceValue = self.price.text
            let list_priceValue = self.list_price.text
            let stock_countValue = self.stock_count.text
            let reminder_stock_countValue = self.reminder_stock_count.text
            
            var error = false
            if nameValue == nil{
                error = true
            }else{
                let nameValueReplacing = nameValue?.replacingOccurrences(of: " ", with: "")
                if nameValueReplacing?.characters.count == 0{
                    error = true
                }else{
                    self.editProduct.name = nameValue!
                }
            }
            
            if error == true{
                self.popAlert(title: "名稱有誤", message: "名稱不可為空值")
                self.closeMask()
                return
            }
            
            self.editProduct.barcode = barcodeValue!
            
            if priceValue == nil{
                error = true
            }else{
                let priceValueReplacing = priceValue?.replacingOccurrences(of: " ", with: "")
                if priceValueReplacing?.characters.count == 0{
                    error = true
                }else{
                    self.editProduct.price = Int(priceValue!)!
                }
            }
            
            if error == true{
                self.popAlert(title: "成本價有誤", message: "成本價不可為空值")
                self.closeMask()
                return
            }
            
            if list_priceValue == nil{
                //error
            }else{
                let list_priceValueReplacing = list_priceValue?.replacingOccurrences(of: " ", with: "")
                if list_priceValueReplacing?.characters.count == 0{
                    error = true
                }else{
                    self.editProduct.list_price = Int(list_priceValue!)!
                }
            }
            
            if error == true{
                self.popAlert(title: "牌價有誤", message: "牌價不可為空值")
                self.closeMask()
                return
            }
            
            if self.stock.isOn == true{
                if stock_countValue == nil{
                    error = true
                }else{
                    let stock_countValueReplacing = stock_countValue?.replacingOccurrences(of: " ", with: "")
                    if stock_countValueReplacing?.characters.count == 0{
                        error = true
                    }else{
                        self.editProduct.stock = true
                        self.editProduct.stock_count = Int(stock_countValue!)!
                    }
                }
                
                if error == true{
                    self.popAlert(title: "庫存數量有誤", message: "庫存數量不可為空值")
                    self.closeMask()
                    return
                }
            }else{
                self.editProduct.stock = false
            }
            
            if self.reminder_stock.isOn == true{
                if reminder_stock_countValue == nil{
                    error = true
                }else{
                    let reminder_stock_countValueReplacing = reminder_stock_countValue?.replacingOccurrences(of: " ", with: "")
                    if reminder_stock_countValueReplacing?.characters.count == 0{
                        error = true
                    }else{
                        self.editProduct.reminder_stock = true
                        self.editProduct.reminder_stock_count = Int(reminder_stock_countValue!)!
                    }
                }
                
                if error == true{
                    self.popAlert(title: "庫存提醒有誤", message: "庫存提醒不可為空值")
                    self.closeMask()
                    return
                }
            }else{
                self.editProduct.reminder_stock = false
            }
            
            self.editProduct.enable = self.enable.isOn
            
            //save
            let parentCategory = self.categoryTree[self.categoryTree.count-1]
            self.editProduct.parent = parentCategory
            self.editProduct.productCategoryId = parentCategory.id
            
            var isAdd = false
            if self.editProduct.id == ""{
                self.editProduct.id = UUID().uuidString
                isAdd = true
            }
            
            if self.editProduct.once_sold == true &&
                (self.editProduct.price != self.oldPrice ||
                    self.editProduct.list_price != self.oldList_price) {
                //delete old and new product to update for the report
                isAdd = true
                
                self.editProduct.deleted = true
                self.editProduct.price = self.oldPrice
                self.editProduct.list_price = self.oldList_price
                
                let replace = self.editProduct.copy()
                replace.id = UUID().uuidString
                replace.list_price = Int(list_priceValue!)!
                replace.price = Int(priceValue!)!
                
                self.dataService.replaceProduct(target: self.editProduct, replaceTo: replace)
                self.replaceProductFinishCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                  target: self,
                                                  selector: #selector(self.replaceProductFinish),
                                                  userInfo: nil,
                                                  repeats: true)
            }else{
                self.dataService.updateProduct(product: self.editProduct, isAdd: isAdd)
                self.updateProductFinishCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                  target: self,
                                                  selector: #selector(self.updateProductFinish),
                                                  userInfo: nil,
                                                  repeats: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var updateProductFinishCount = 0
    
    func updateProductFinish(){
        if updateProductFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.updateProductIsRunning == false{
                timer.invalidate()
                getProduct()
            }
        }
        updateProductFinishCount += 1
    }
    
    var replaceProductFinishCount = 0
    
    func replaceProductFinish(){
        if replaceProductFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.replaceProductIsRunning == false{
                timer.invalidate()
                getProduct()
            }
        }
        replaceProductFinishCount += 1
    }
    
    func getProduct(){
        dataService.getProduct(parentId: categoryTree[categoryTree.count - 1].id)
        checkGetProductsFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkGetProductsFinish),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    var checkGetProductsFinishCount = 0
    
    func checkGetProductsFinish(){
        if checkGetProductsFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.loadIngProduct == false{
                timer.invalidate()
                // prepare reload data
                //success
                let alert =  UIAlertController(title: "", message: "儲存成功", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (alert: UIAlertAction!) in
                    self.closeMask()
                    self.performSegue(withIdentifier: "goToProduct", sender: nil)
                }))
                present(alert, animated: true, completion: nil)
            }
        }
        checkGetProductsFinishCount += 1
    }
    
    func popAlert(title:String, message:String){
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor
        closeMask()
        maskActive.startAnimating()
        barcode.placeholder = "非必填"
        
        if editProduct.id != ""{
            name.text = editProduct.name
            barcode.text = editProduct.barcode
            price.text = String(editProduct.price)
            list_price.text = String(editProduct.list_price)
            stock_count.text = String(editProduct.stock_count)
            reminder_stock_count.text = String(editProduct.reminder_stock_count)
            
            oldPrice = editProduct.price
            oldList_price = editProduct.list_price
            
            stock.isEnabled = false
            
            if editProduct.stock == true{
                stock.isOn = true
                stock_count.isHidden = false
            }else{
                stock.isOn = false
                stock_count.isHidden = true
            }
            
            if editProduct.reminder_stock == true{
                reminder_stock.isOn = true
                reminder_stock_count.isHidden = false
            }else{
                reminder_stock.isOn = false
                reminder_stock_count.isHidden = true
            }
            
            if editProduct.enable == true{
                enable.isOn = true
            }else{
                enable.isOn = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProduct"{
            if let dvc = segue.destination as? ProductViewController{
                dvc.categoryTree = categoryTree
                viewSetting.titleBarText = "商品"
                viewSetting.titleBackButtonIsHidden = true
            }
        }
    }
}
