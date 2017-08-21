//
//  ProductCategoryViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/26.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class ProductCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataService = DataService.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    
    var nowData = DataService.sharedInstance().productCategorys
    
    var parentProductCategory :ProductCategory? = nil
    
    var targetProductCategory :ProductCategory? = nil
    
    var categoryTree = [ProductCategory]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var timer:Timer!
    
    var styleColor = UIColor()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCategory: UIButton!
    
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    @IBOutlet weak var maskView: UIView!
    
    @IBAction func addCategory(_ sender: UIButton) {
        targetProductCategory = ProductCategory()
        popUpAlertWithDefault(defaultValue: "", title: "新增類別")
    }
    
    @IBOutlet weak var addProduct: UIButton!
    
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if parentProductCategory == nil{
            nowData = dataService.productCategorys
        }
        return nowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? ProductCategoryTableViewCell
        
        let index = indexPath.row
        
        let productCategory = nowData[index]
        cell?.cellTextLabel?.text = productCategory.name
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var result = [UITableViewRowAction]()
        let row = indexPath.row
        let delete  = UITableViewRowAction(style: .normal, title: "刪除") { (rowAction, indexPath) in
            self.deleteProductCategory(row:row)
        }
        delete.backgroundColor = UIColor(red: 204/255, green: 64/255, blue: 66/255, alpha: 1.0)
        result.append(delete)
        
        let edit = UITableViewRowAction(style: .normal, title: "修改") { (rowAction, indexPath) in
            self.updateProductCategory(row:row)
        }
        edit.backgroundColor = UIColor(red: 88/255, green: 178/255, blue: 220/255, alpha: 1.0)
        result.append(edit)
        
        return result
    }
    
    func updateProductCategory(row:Int){
        targetProductCategory = nowData[row]
        popUpAlertWithDefault(defaultValue: targetProductCategory?.name, title: "修改類別")
    }
    
    func deleteProductCategory(row:Int){
        openMask()
        targetProductCategory = nowData[row]
        if (targetProductCategory?.childrenCategoryCount)! > 0 ||
            (targetProductCategory?.childrenProductCount)! > 0 {
            popAlert(title: "無法刪除", message: "類別下有子類別 or 商品")
            closeMask()
            return;
        }
        let alert =  UIAlertController(title: "刪除確認", message: "確定刪除這一個類別？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
            // do delete file
            
            if !self.dataService.isValidInternet(){
                self.popAlert(title: "網路錯誤", message: "請檢查網路連線")
                self.closeMask()
                return;
            }
            
            if self.parentProductCategory != nil{
                self.targetProductCategory?.parent = self.parentProductCategory
            }
            
            self.dataService.deleteProductCategory(productCategory: self.targetProductCategory!)
            self.checkDeleteProductCategoryFinishCount = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                              target: self,
                                              selector: #selector(self.checkDeleteProductCategoryFinish),
                                              userInfo: nil,
                                              repeats: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var checkDeleteProductCategoryFinishCount = 0
    
    func checkDeleteProductCategoryFinish(){
        if checkDeleteProductCategoryFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.deleteProductCategoryIsRunning == false{
                timer.invalidate()
                // prepare reload data
                getProductCategory()
            }
        }
        checkDeleteProductCategoryFinishCount += 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentProductCategory = nowData[indexPath.row]
        openMask()
        categoryTree.append(parentProductCategory!)
        if (parentProductCategory?.childrenProductCount)! > 0{
            getProduct()
            print("getProduct() ================")
        }else{
            reflashCategoryTreeContent()
            getProductCategory()
        }
        
    }
    
    func getProduct(){
        openMask()
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
            closeMask()
            return;
        }else {
            if dataService.loadIngProduct == false{
                timer.invalidate()
                closeMask()
                performSegue(withIdentifier: "goToProduct", sender: nil)
            }
        }
        checkGetProductsFinishCount += 1
    }
    
    func getProductCategory(){
        self.openMask()
        var queryParentId = ""
        if parentProductCategory != nil{
            queryParentId = (parentProductCategory?.id)!
        }
        dataService.getProductCategorys(parentId: queryParentId)
        checkGetProductCategorysFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkGetProductCategorysFinish),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    var checkGetProductCategorysFinishCount = 0
    
    func checkGetProductCategorysFinish(){
        if checkGetProductCategorysFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.loadIngProductCategorys == false{
                timer.invalidate()
                // prepare reload data
                
                nowData = dataService.productCategorys
                tableView.reloadData()
                viewShowReload()
                closeMask()
            }
        }
        checkGetProductCategorysFinishCount += 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditProduct"{
            viewSetting.titleBarText = "編輯商品"
            viewSetting.titleBackButtonIsHidden = false
            if let dvc = segue.destination as? EditProductViewController{
                dvc.categoryTree = categoryTree
            }
        }
        
        if segue.identifier == "goToProduct"{
            viewSetting.titleBarText = "商品"
            viewSetting.titleBackButtonIsHidden = true
            if let dvc = segue.destination as? ProductViewController{
                dvc.categoryTree = categoryTree
            }
        }
    }
    
    
    func popUpAlertWithDefault(defaultValue:String?, title:String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "請輸入類別名稱"
            textfield.text = defaultValue
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            self.openMask()
            if let inputText = alert.textFields?[0].text{
                if inputText != ""{
                    
                    if !self.dataService.isValidInternet(){
                        self.popAlert(title: "網路錯誤", message: "請檢查網路連線")
                        self.closeMask()
                        return;
                    }
                    
                    if(self.targetProductCategory?.id == ""){
                        //新增
                        self.targetProductCategory?.id = UUID().uuidString
                        self.targetProductCategory?.name = inputText
                        
                        var nextSort = -1
                        for item in self.nowData{
                            if item.sort > nextSort{
                                nextSort = item.sort
                            }
                        }
                        
                        self.targetProductCategory?.sort = (nextSort+1)
                        if self.parentProductCategory != nil{
                            self.targetProductCategory?.parentId = (self.parentProductCategory?.id)!
                            self.targetProductCategory?.parent = self.parentProductCategory
                        }else{
                            self.targetProductCategory?.parentId = ""
                        }
                        self.dataService.addProductCategory(productCategory: self.targetProductCategory!)
                        self.checkAddProductCategoryFinishCount = 0
                        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                          target: self,
                                                          selector: #selector(self.checkAddProductCategoryFinish),
                                                          userInfo: nil,
                                                          repeats: true)
                    }else{
                        //修改
                        self.targetProductCategory?.name = inputText
                        self.dataService.updateProductCategory(productCategory: self.targetProductCategory!)
                        self.checkUpdateProductCategoryFinishCount = 0
                        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                          target: self,
                                                          selector: #selector(self.checkUpdateProductCategoryFinish),
                                                          userInfo: nil,
                                                          repeats: true)
                    }
                }else{
                    self.popAlert(title: "參數有誤", message: "類別名稱不可為空值")
                    self.closeMask()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var checkAddProductCategoryFinishCount = 0
    func checkAddProductCategoryFinish(){
        if checkAddProductCategoryFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.updateProductCategoryIsRunning == false{
                timer.invalidate()
                // prepare reload data
                getProductCategory()
            }
        }
        checkAddProductCategoryFinishCount += 1
    }
    
    var checkUpdateProductCategoryFinishCount = 0
    func checkUpdateProductCategoryFinish(){
        if checkUpdateProductCategoryFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.updateProductCategoryIsRunning == false{
                timer.invalidate()
                // prepare reload data
                getProductCategory()
            }
        }
        checkUpdateProductCategoryFinishCount += 1
    }
    
    func popAlert(title:String, message:String){
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func viewShowReload(){
        if parentProductCategory == nil{
            addProduct.isHidden = true
        }else if parentProductCategory != nil{
            if parentProductCategory?.childrenCategoryCount == 0 && parentProductCategory?.childrenProductCount == 0{
                addCategory.isHidden = false
                addProduct.isHidden = false
            }
            if (parentProductCategory?.childrenCategoryCount)! > 0 && parentProductCategory?.childrenProductCount == 0{
                addCategory.isHidden = false
                addProduct.isHidden = true
            }
            
            if parentProductCategory?.childrenCategoryCount == 0 && (parentProductCategory?.childrenProductCount)! > 0{
                addCategory.isHidden = true
                addProduct.isHidden = false
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor
        if categoryTree.count == 0{
            let rootProductCategory = ProductCategory()
            rootProductCategory.name = "主目錄"
            categoryTree.append(rootProductCategory)
        }
        
        viewShowReload()
        closeMask()
        maskActive.startAnimating()        
        addCategory.setTitleColor(styleColor, for: .normal)
        addProduct.setTitleColor(styleColor, for: .normal)
        
        
        
        reflashCategoryTreeContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    let buttonPadding:CGFloat = 10
    var xOffset:CGFloat = 10
    
    func reflashCategoryTreeContent(){
        for item in scrollView.subviews{
            item.removeFromSuperview()
        }
        
        if categoryTree.isEmpty == false{
            for index in 0...(categoryTree.count-1){
                let item = categoryTree[index]
                let name = item.name
                let width = name.characters.count * 20
                if index != (categoryTree.count-1){
                    let button = UIButton()
                    button.tag = index
                    button.setTitle(name, for: .normal)
                    button.setTitleColor(styleColor, for: .normal)
                    button.setTitleColor(UIColor.black, for: .highlighted)
                    button.addTarget(self, action: #selector(ProductCategoryViewController.treeButtonEvent(sender:)), for: .touchUpInside)
                    
                    button.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: CGFloat(width), height: 20)
                    xOffset = xOffset + CGFloat(buttonPadding) + button.frame.size.width
                    scrollView.addSubview(button)
                    let label = UILabel()
                    label.text = ">"
                    label.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: 20, height: 20)
                    xOffset = xOffset + CGFloat(buttonPadding) + label.frame.size.width
                    scrollView.addSubview(label)
                }else{
                    let label = UILabel()
                    label.text = name
                    label.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: CGFloat(width), height: 20)
                    xOffset = xOffset + CGFloat(buttonPadding) + label.frame.size.width
                    scrollView.addSubview(label)
                }
            }
        }
        scrollView.contentSize = CGSize(width: xOffset, height: 1.0)
        xOffset = 10
    }
    
    func treeButtonEvent(sender: UIButton){
        let tag = sender.tag
        parentProductCategory = categoryTree[tag]
        
        while (tag+1) != categoryTree.count{
            categoryTree.remove(at: (categoryTree.count - 1))
        }
        
        reflashCategoryTreeContent()
        getProductCategory()
    }
}
