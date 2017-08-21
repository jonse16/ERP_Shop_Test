//
//  MessageProductViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/15.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class MessageProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dataService = DataService.sharedInstance()
    let message = Message.sharedInstance()
    let dataFormate = DateFormatter()
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataService.messageReadHistorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? MessageProductTableViewCell
        let mrh = dataService.messageReadHistorys[indexPath.row];
        dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell?.body.text = mrh.body
        cell?.time.text = dataFormate.string(from: mrh.createDateTime)
        return cell!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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