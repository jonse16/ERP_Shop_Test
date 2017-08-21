//
//  EditUserViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/23.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditUserViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var dataService = DataService.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    
    var editUser:User?
    
    var pickViewSelectName = ["老闆","經理（店長）","職員"]
    var pickViewSelectValue = ["boss","manager","emp"]
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var pickView: UIPickerView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    var styleColor = UIColor()
    
    var timer:Timer!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitAction(_ sender: UIButton) {
        if !dataService.isValidInternet(){
            popAlert(title: "網路錯誤", message: "請檢查網路連線")
            return;
        }
        
        openMask()
        let name = nameText.text!
        let replaced = (name as NSString).replacingOccurrences(of: " ", with: "")
        if replaced == ""{
            popAlert(title: "姓名有誤", message: "姓名不可為空值")
            return;
        }
        
        editUser?.name = nameText.text!
        editUser?.title = pickViewSelectValue[pickView.selectedRow(inComponent: 0)]
        if editUser?.uid == ""{
            let username = usernameText.text!
            let usernameReplaced = (username as NSString).replacingOccurrences(of: " ", with: "")
            if usernameReplaced == ""{
                popAlert(title: "帳號有誤", message: "帳號不可為空值")
                return;
            }else if isValidEmail(testStr: usernameReplaced) == false{
                popAlert(title: "帳號有誤", message: "帳號格式有誤 請使用Email 格式")
                return;
            }
                                    
            let password = passwordText.text!
            let passwordReplaced = (password as NSString).replacingOccurrences(of: " ", with: "")
            if passwordReplaced == ""{
                popAlert(title: "密碼有誤", message: "密碼不可為空值")
                return;
            }else if passwordReplaced.characters.count < 6{
                popAlert(title: "密碼有誤", message: "密碼長度須大於6個字元")
                return;
            }
            
            Auth.auth().createUser(withEmail: usernameReplaced, password: passwordReplaced) {(user, error) in
                if error == nil{
                    print("createUser success");
                    user?.sendEmailVerification(completion: { (sendEmailVerificationError) in
                        if sendEmailVerificationError == nil{
                            self.editUser?.uid = (user?.uid)!
                            self.dataService.companyUsers.append(self.editUser!)
                            self.dataService.updateUser(uid: (self.editUser?.uid)!, companyId: (self.editUser?.companyId)!)
                            self.checkUpdateUserFinishCount = 0
                            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                              target: self,
                                                              selector: #selector(self.checkUpdateUserFinish),
                                                              userInfo: nil,
                                                              repeats: true)
                        }else{
                            self.popAlert(title: "註冊失敗", message: error!.localizedDescription)
                        }
                    })
                }else{
                    print("createUser Fail !! reason = "+error!.localizedDescription);
                    self.popAlert(title: "註冊失敗", message: error!.localizedDescription)
                }
            }
        }else{            
            dataService.updateUser(uid: (editUser?.uid)!, companyId: (editUser?.companyId)!)
            self.checkUpdateUserFinishCount = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                              target: self,
                                              selector: #selector(self.checkUpdateUserFinish),
                                              userInfo: nil,
                                              repeats: true)
        }
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
                performSegue(withIdentifier: "backToCompany", sender: nil)
            }
        }
        checkUpdateUserFinishCount += 1
    }
//==================================================================================================================
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    func popAlert(title:String, message:String){
        closeMask()
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidInternet () -> Bool{
        let reachability = Reachability(hostName: "www.apple.com")
        if reachability?.currentReachabilityStatus().rawValue == 0{
            print("no internet")
            return false;
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickViewSelectName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickViewSelectName[row]
    }    

    override func viewDidLoad() {
        super.viewDidLoad()
        styleColor = viewSetting.styleColor
        submitButton?.setTitleColor(UIColor.white, for: .normal)
        submitButton?.setTitleColor(UIColor.black, for: .highlighted)
        submitButton?.layer.cornerRadius = 5.0
        submitButton?.layer.masksToBounds = true
        submitButton?.backgroundColor = styleColor

        if editUser?.uid != ""{
            usernameLabel.isHidden = true
            usernameText.isHidden = true
            passwordLabel.isHidden = true
            passwordText.isHidden = true
        }
        nameText.text = editUser?.name

        var titleRow = 0
        if editUser?.title == "manager"{
            titleRow = 1
        }
        if editUser?.title == "emp"{
            titleRow = 2
        }
        pickView.selectRow(titleRow, inComponent: 0, animated: true)
        maskActive.startAnimating()
        closeMask()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
