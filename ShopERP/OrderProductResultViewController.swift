//
//  OrderProductResultViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/19.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderProductResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var editOrder = TempOrderItems.sharedInstance().order
    var dataService = DataService.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    var styleColor = UIColor()
    var result = [Int:Int]()
    @IBOutlet weak var addToOrder: UIButton!    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addToOrder(_ sender: UIButton) {
        let alert =  UIAlertController(title: "加入訂單確認", message: "確認加入？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
            for item in self.result.keys{
                let oiCount = self.result[item]
                let product = self.dataService.orderProductResult[item]
                
                let oi =  OrderItem()
                oi.id = UUID().uuidString
                oi.productId = product.id
                oi.productName = product.name
                oi.count = oiCount!
                oi.total = product.list_price * oiCount!
                oi.orderId = self.editOrder.id
                oi.product = product
                self.editOrder.items.append(oi)
            }
            
            var totalCount = 0
            for item in (self.editOrder.items){
                totalCount += item.total
            }
            self.editOrder.total = totalCount
            self.editOrder.totalCount = totalCount
            
            self.goToOtherPage(segueIdentifier: "goBackToOrder")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func goToOtherPage(segueIdentifier:String){
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataService.orderProductResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? OrderProductResultTableViewCell
        
        let product = dataService.orderProductResult[indexPath.row]
        cell?.product = product
        
        cell?.name.text = product.name
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
        
        if let oldCountInt = result[indexPath.row]{
            cell!.countInt = oldCountInt
        }
        
        cell?.count.text = "數量 : \(String(describing: cell!.countInt))"
        cell?.plus.tag = indexPath.row
        cell?.plus.addTarget(self, action: #selector(OrderProductResultViewController.plus(sender:)), for: .touchUpInside)
        cell?.plus.setTitleColor(styleColor, for: .normal)
        cell?.less.tag = indexPath.row
        cell?.less.addTarget(self, action: #selector(OrderProductResultViewController.less(sender:)), for: .touchUpInside)
        cell?.less.setTitleColor(styleColor, for: .normal)
        
        return cell!
    }
    
    func plus(sender: UIButton){
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? OrderProductResultTableViewCell{
            let product = cell.product
            var countInt = cell.countInt
            let count = cell.count
            if (product?.stock)! == true
                && (product?.stock_count)! < (countInt+1){
            }else{
                countInt += 1
                count?.text = "數量 : \(countInt)"
                if countInt > 0{
                    cell.countInt = countInt
                    result[sender.tag] = countInt
                }
            }
        }
    }
    
    func less(sender: UIButton){
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? OrderProductResultTableViewCell{
            var countInt = cell.countInt
            let count = cell.count
            if countInt > 0{
                countInt -= 1
                count?.text = "數量 : \(countInt)"
                cell.countInt = countInt
                if countInt == 0{
                    result.removeValue(forKey: sender.tag)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor                
        addToOrder.setTitleColor(styleColor, for: .normal)
        back.setTitleColor(styleColor, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
