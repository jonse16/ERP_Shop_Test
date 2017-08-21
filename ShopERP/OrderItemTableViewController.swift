//
//  OrderItemTableViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/8.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class OrderItemTableViewController: UITableViewController {
    
    var orderItems = [OrderItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("OrderItemTableViewController orderItems.count = \(orderItems.count)")
        return orderItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? OrderItemTableViewCell
        let orderItem = orderItems[indexPath.row]
        cell?.name.text = orderItem.productName
        var count = ""
        count = String(orderItem.count)
        cell?.count.text = "x"+count
        var total = ""
        total = String(orderItem.total)
        cell?.total.text = total
        
        let superView = cell?.name.superview
        print("superView!.frame.size.height = \(superView!.frame.size.height)")
        print("superView!.frame.size.width = \(superView!.frame.size.width)")
        cell?.name.heightAnchor.constraint(equalToConstant: superView!.frame.size.height).isActive = true
        cell?.name.widthAnchor.constraint(equalToConstant: superView!.frame.size.width * 0.7).isActive = true
        cell?.name.leadingAnchor.constraint(equalTo: superView!.leadingAnchor, constant: 0).isActive = true

        cell?.count.heightAnchor.constraint(equalToConstant: superView!.frame.size.height).isActive = true
        cell?.count.widthAnchor.constraint(equalToConstant: superView!.frame.size.width * 0.15).isActive = true
        cell?.count.leadingAnchor.constraint(equalTo: (cell?.name.trailingAnchor)!, constant: 0).isActive = true
        
        cell?.total.heightAnchor.constraint(equalToConstant: superView!.frame.size.height).isActive = true
        cell?.total.widthAnchor.constraint(equalToConstant: superView!.frame.size.width * 0.15).isActive = true
        cell?.total.leadingAnchor.constraint(equalTo: (cell?.count!.trailingAnchor)!, constant: 0).isActive = true
        return cell!
    }
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
