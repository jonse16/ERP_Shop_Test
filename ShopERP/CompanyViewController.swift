//
//  CompanyViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/20.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CompanyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var dataService = DataService.sharedInstance()
    
    var users = DataService.sharedInstance().companyUsers
    var viewSetting = ViewSetting.sharedInstance()
    
    @IBOutlet weak var myTableView: UITableView!
    
    var timer:Timer!
    
    @IBOutlet weak var maskView: UIView!
    
    @IBOutlet weak var maskActivity: UIActivityIndicatorView!
    
    var styleColor = UIColor()
    
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CompanyCellTableViewCell
        
        let user = users[indexPath.row]
        
        if user.uid == ""{
            //取消點擊 可不做
            cell?.button.setTitle("+", for: .normal)
            cell?.label?.text = user.name
            cell?.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
        }else{
            cell?.button.isHidden = true
            cell?.label?.text = "     "+user.name
        }
        cell?.button.setTitleColor(styleColor, for: .normal)
        cell?.button.tag = indexPath.row
        adCustomButtonEvent(button: (cell?.button)!)
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var result = [UITableViewRowAction]()
        let user = users[indexPath.row]
        
        if user.uid == ""{
        }else{
            let delete  = UITableViewRowAction(style: .normal, title: "刪除") { (rowAction, indexPath) in
                self.deleteUserUser(user:user)
            }
            delete.backgroundColor = UIColor(red: 204/255, green: 64/255, blue: 66/255, alpha: 1.0)
            result.append(delete)
            
            delete.backgroundColor = UIColor(red: 88/255, green: 178/255, blue: 220/255, alpha: 1.0)
            result.append(delete)
        }
        return result
    }
    
    func adCustomButtonEvent(button:UIButton){
        let user = users[button.tag]
        if user.uid == ""{
            button.addTarget(self, action: #selector(CompanyViewController.goToAddNewUser(sender:)), for: .touchUpInside)
        }
    }
    
    var editUser:User?
    
    func goToAddNewUser(sender: UIButton){
        let buttonUser = users[sender.tag]
        
        let currentUser = dataService.currentUser
        editUser = User()
        editUser?.companyId = (currentUser?.companyId)!
        editUser?.title = buttonUser.title
        performSegue(withIdentifier: "goToEditUser", sender: nil)
    }
    
    func deleteUserUser(user: User){
        editUser = user
        let alert =  UIAlertController(title: "刪除確認", message: "您確定要刪除使用者？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: deleteUser(sender: )))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func deleteUser(sender: UIAlertAction){
        if !dataService.isValidInternet(){
            popAlert(title: "網路錯誤", message: "請檢查網路連線")
            return;
        }
        editUser?.deleted = true
        dataService.updateUser(uid: (editUser?.uid)!, companyId: (editUser?.companyId)!)
        openMask()
        self.checkUpdateUserFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkUpdateUserFinish),
                                          userInfo: nil,
                                          repeats: true)
        
    }
    
    var checkUpdateUserFinishCount = 0
    
    func checkUpdateUserFinish(){
        if checkUpdateUserFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            return;
        }else {
            if dataService.updateUserIsRunning == false{
                timer.invalidate()
                users = DataService.sharedInstance().companyUsers
                myTableView.reloadData()
                closeMask()
            }
        }
        checkUpdateUserFinishCount += 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if user.uid == ""{
        }else{
            let utvc = tableView.cellForRow(at: indexPath) as? CompanyCellTableViewCell
            utvc?.label.textColor = styleColor
            editUser = users[indexPath.row]
            performSegue(withIdentifier: "goToEditUser", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let utvc = tableView.cellForRow(at: indexPath) as? CompanyCellTableViewCell
        utvc?.label.textColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1.0)
        return indexPath;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditUser"{
            if let dvc = segue.destination as? EditUserViewController{
                dvc.editUser = editUser
                if editUser?.uid == ""{
                    viewSetting.titleBarText = "新增使用者"
                }else{
                    viewSetting.titleBarText = "修改使用者"
                }
                viewSetting.titleBackButtonIsHidden = false                
            }
        }
        
    }
    
    func popAlert(title:String, message:String){
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor
        maskActivity.startAnimating()
        closeMask()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
