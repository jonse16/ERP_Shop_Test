//
//  ProductViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/4.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var dataService = DataService.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    var categoryTree = [ProductCategory]()
    var timer:Timer!
    var styleColor = UIColor()
    var products = [Product]()
    var editProduct = Product()
    
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    
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
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? ProductTableViewCell
        let index = indexPath.row
        let product = products[index]
        cell?.cellTextLabel.text = product.name
        
        if product.stock == true &&
            product.reminder_stock == true &&
            product.stock_count <= product.reminder_stock_count{
            cell?.stock.textColor = UIColor.red
        }
        
        if product.stock == true {
            cell?.stock.text = "庫存 : \(product.stock_count)"
        }else{
            cell?.stock.text = "無庫存商品"
            cell?.stock.textColor = UIColor.blue
        }
        
        print("product.enable = \(product.enable)")
        if product.enable == false{
            cell?.backgroundColor = UIColor(red: 248/255, green: 195/255, blue: 205/255, alpha: 1.0)
        }else{
            cell?.backgroundColor = UIColor.white
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var result = [UITableViewRowAction]()
        let product = products[indexPath.row]
        
        let delete  = UITableViewRowAction(style: .normal, title: "刪除") { (rowAction, indexPath) in
            self.deleteProduct(product:product)
        }
        delete.backgroundColor = UIColor(red: 204/255, green: 64/255, blue: 66/255, alpha: 1.0)
        result.append(delete)

        var title = ""
        if product.enable == true{
            title = "下架"
        }else{
            title = "上架"
        }
        let edit = UITableViewRowAction(style: .normal, title: title) { (rowAction, indexPath) in
            self.enableProduct(product:product)
        }
        edit.backgroundColor = UIColor(red: 88/255, green: 178/255, blue: 220/255, alpha: 1.0)
        result.append(edit)
        
        return result
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editProduct = products[indexPath.row]
        performSegue(withIdentifier: "goToEditProduct", sender: nil)
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
            return;
        }else {
            if dataService.loadIngProduct == false{
                timer.invalidate()
                // prepare reload data
                
                products = dataService.products
                tableView.reloadData()
                self.closeMask()
            }
        }
        checkGetProductsFinishCount += 1
    }
    
    
    @IBAction func addProduct(_ sender: UIButton) {
        editProduct = Product()
        var nextSort = -1
        for item in products{
            if item.sort > nextSort{
                nextSort = item.sort
            }
        }
        editProduct.sort = (nextSort+1)
        performSegue(withIdentifier: "goToEditProduct", sender: nil)
    }
    
    
    func enableProduct(product:Product){
        var message = ""
        if product.enable == true{
            product.enable = false
            message = "確定下架？"
        }else{
            product.enable = true
            message = "確定上架？"
        }
        let alert =  UIAlertController(title: "上/下架確認", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
            self.openMask()
            self.dataService.updateProduct(product: product, isAdd: false)
            self.updateProductFinishCount = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                              target: self,
                                              selector: #selector(self.updateProductFinish),
                                              userInfo: nil,
                                              repeats: true)
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
    
    func deleteProduct(product:Product){
        let alert =  UIAlertController(title: "刪除確認", message: "確認刪除?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
            self.openMask()
            product.deleted = true
            product.parent = self.categoryTree[self.categoryTree.count - 1]
            self.dataService.deleteProduct(product: product)
            self.updateProductFinishCount = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                              target: self,
                                              selector: #selector(self.deleteProductFinish),
                                              userInfo: nil,
                                              repeats: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var deleteProductFinishCount = 0
    
    func deleteProductFinish(){
        if deleteProductFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            self.closeMask()
            return;
        }else {
            if dataService.deleteProductIsRunning == false{
                timer.invalidate()
                let parent = self.categoryTree[self.categoryTree.count - 1]
                if parent.childrenProductCount == 0{
                    dataService.getProductCategorys(parentId: parent.id)
                    self.checkGetProductCategorysFinishCount = 0
                    self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                      target: self,
                                                      selector: #selector(self.checkGetProductCategorysFinish),
                                                      userInfo: nil,
                                                      repeats: true)
                }else{
                    getProduct()
                }
            }
        }
        deleteProductFinishCount += 1
    }
    
    var checkGetProductCategorysFinishCount = 0
    func checkGetProductCategorysFinish(){
        if checkGetProductCategorysFinishCount == 20{
            print("checkGetProductCategorysFinishCount == 20")
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            return;
        }else {
            if dataService.loadIngProductCategorys == false{
                timer.invalidate()
                self.closeMask()
                performSegue(withIdentifier: "goToProductCatagory", sender: nil)
            }
        }
        checkGetProductCategorysFinishCount += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor
        closeMask()
        maskActive.startAnimating()
        products = dataService.products
        reflashCategoryTreeContent()
        
        addProduct.setTitleColor(styleColor, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        while (tag+1) != categoryTree.count{
            categoryTree.remove(at: (categoryTree.count - 1))
        }
        
        let parent = self.categoryTree[tag]
        dataService.getProductCategorys(parentId: parent.id)
        self.checkGetProductCategorysFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkGetProductCategorysFinish),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func popAlert(title:String, message:String){
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProductCatagory"{
            if let dvc = segue.destination as? ProductCategoryViewController{
                dvc.categoryTree = categoryTree
                dvc.parentProductCategory = categoryTree[categoryTree.count-1]
                viewSetting.titleBarText = "商品類別"
                viewSetting.titleBackButtonIsHidden = true
            }
        }
        
        if segue.identifier == "goToEditProduct"{
            if let dvc = segue.destination as? EditProductViewController{
                dvc.categoryTree = categoryTree
                dvc.editProduct = editProduct
                viewSetting.titleBarText = "編輯商品"
                viewSetting.titleBackButtonIsHidden = false
            }
        }
    }
}
