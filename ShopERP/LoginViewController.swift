//
//  LoginViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/15.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var maskView: UIView!
    
    @IBOutlet weak var maskActive: UIActivityIndicatorView!
    
    let dataService = DataService.sharedInstance()
    
    var timer:Timer!
    
    func openMask(){
        maskView.isHidden = false
    }
    
    func closeMask(){
        maskView.isHidden = true
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        openMask()
        if !dataService.isValidInternet(){
            popAlert(title: "網路錯誤", message: "請檢查網路連線")
            return;
        }
        
        if username.text == nil || username.text!.isEmpty{
            popAlert(title: "帳號有誤", message: "帳號不可為空值")
            return;
        }else if isValidEmail(testStr: username.text!) == false{
            popAlert(title: "帳號有誤", message: "帳號格式有誤 請使用Email 格式")
            return;
        }
        
        if password.text == nil || password.text!.isEmpty {
            popAlert(title: "密碼有誤", message: "密碼不可為空值")
            return;
        }else if password.text!.characters.count < 6{
            popAlert(title: "密碼有誤", message: "密碼長度須大於6個字元")
            return;
        }
        
        Auth.auth().signIn(withEmail: username.text!, password: password.text!) {(user, error) in
            if error == nil{
                if(!Bool(user!.isEmailVerified.description)!){
                    self.popAlert(title: "認證有誤", message: "請先收取驗證信並執行驗證")
                    return;
                }else{
                    self.dataService.getCurrentUser()
                    self.checkGetCurrentUserFinishCount = 0
                    self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                      target: self,
                                                      selector: #selector(self.checkGetCurrentUserFinish),
                                                      userInfo: nil,
                                                      repeats: true)
                }
            }else{
                print("SignIn Fail !! reason = "+error!.localizedDescription);
                self.popAlert(title: "登入失敗", message: error!.localizedDescription)
                return;
            }
        }
    }
    
    var checkGetCurrentUserFinishCount = 0
    
    func checkGetCurrentUserFinish(){
        if checkGetCurrentUserFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            return;
        }else {
            if dataService.loadIngCurrentUser == false{
                timer.invalidate()
                if dataService.currentUser != nil{
                    if dataService.currentUser?.validate == false{
                        dataService.getCompanyAllUser()
                        self.checkGetCompanyAllUserFinishCount = 0
                        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                          target: self,
                                                          selector: #selector(self.checkGetCompanyAllUserFinish),
                                                          userInfo: nil,
                                                          repeats: true)
                        
                        
                    }else if(dataService.currentUser?.enable == false || dataService.currentUser?.deleted == true){
                        popAlert(title: "登入錯誤", message: "帳號已停用 or 刪除")
                    }else{
                        dataService.writeToken(token:Messaging.messaging().fcmToken!)
                        self.closeMask()
                        self.performSegue(withIdentifier: "goToMenu", sender: nil)
                    }
                }else{
                    popAlert(title: "資料錯誤", message: "資料毀損無法使用")
                    return;
                }
            }
        }
        checkGetCurrentUserFinishCount += 1
    }
    
    var checkGetCompanyAllUserFinishCount = 0
    
    func checkGetCompanyAllUserFinish(){
        if checkGetCompanyAllUserFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            return;
        }else {
            if dataService.loadIngCompanyAllUser == false{
                timer.invalidate()
                for item in dataService.companyUsers{
                    if  item.uid == dataService.currentUser?.uid{
                        item.validate = true
                        break;
                    }
                }
                
                dataService.updateUser(uid: (dataService.currentUser?.uid)!, companyId: (dataService.currentUser?.companyId)!)
                self.checkUpdateUserFinishCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                  target: self,
                                                  selector: #selector(self.checkUpdateUserFinish),
                                                  userInfo: nil,
                                                  repeats: true)
            }
        }
        checkGetCompanyAllUserFinishCount += 1
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
                self.closeMask()
                self.performSegue(withIdentifier: "goToMenu", sender: nil)
            }
        }
        checkUpdateUserFinishCount += 1
    }
    
    //================================================================================================
    
    @IBAction func create(_ sender: UIButton) {
        openMask()
        if !dataService.isValidInternet(){
            popAlert(title: "網路錯誤", message: "請檢查網路連線")
            return;
        }
        
        if username.text == nil || username.text!.isEmpty{
            popAlert(title: "帳號有誤", message: "帳號不可為空值")
            return;
        }else if isValidEmail(testStr: username.text!) == false{
            popAlert(title: "帳號有誤", message: "帳號格式有誤 請使用Email 格式")
            return;
        }
        
        if password.text == nil || password.text!.isEmpty {
            popAlert(title: "密碼有誤", message: "密碼不可為空值")
            return;
        }else if password.text!.characters.count < 6{
            popAlert(title: "密碼有誤", message: "密碼長度須大於6個字元")
            return;
        }
        
        Auth.auth().createUser(withEmail: username.text!, password: password.text!) {(user, error) in
            if error == nil{
                print("createUser success");
                user?.sendEmailVerification(completion: { (sendEmailVerificationError) in
                    if sendEmailVerificationError == nil{
                        let newUser = User()
                        newUser.uid = (user?.uid)!
                        newUser.title = "boss"
                        newUser.name = "公司經營者"
                        self.dataService.createUser(user: newUser)
                        self.checkCreateUserFinishCount = 0
                        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                          target: self,
                                                          selector: #selector(self.checkCreateUserFinish),
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
    }
    
    var checkCreateUserFinishCount = 0
    func checkCreateUserFinish(){
        if checkCreateUserFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            return;
        }else if self.dataService.createUserIsRunning == false{
            timer.invalidate()
            
            let currentUser = dataService.currentUser
            if currentUser != nil{
                if currentUser?.companyId == ""{
                    dataService.createCompany(user: currentUser!)
                    checkCreateCompanyFinishCount = 0
                    self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                                      target: self,
                                                      selector: #selector(self.checkCreateCompanyFinish),
                                                      userInfo: nil,
                                                      repeats: true)
                }else{
                    self.popAlert(title: "帳號建立成功", message: "請先至帳號email收取驗證信")
                }
            }else{
                self.popAlert(title: "帳號建立失敗", message: "請重新執行")
                return
            }
        }
        checkCreateUserFinishCount += 1
    }
    
    var checkCreateCompanyFinishCount = 0
    func checkCreateCompanyFinish(){
        if checkCreateCompanyFinishCount == 20{
            timer.invalidate()
            popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ")
            return;
        }else if dataService.createCompanyIsRunning == false{
            timer.invalidate()
            if dataService.currentUser?.companyId == ""{
                self.popAlert(title: "帳號建立失敗", message: "請重新執行")
                return
            }else{
                self.popAlert(title: "帳號建立成功", message: "請先至帳號email收取驗證信")
            }
        }
    }
    
    //================================================================================================
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maskActive.startAnimating()        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
