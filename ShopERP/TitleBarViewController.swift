//
//  TitleBarViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/6/19.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class TitleBarViewController: UIViewController {
    
    var dataService = DataService.sharedInstance()
    var viewSetting = ViewSetting.sharedInstance()
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBAction func backEvent(_ sender: UIButton) {
        if viewSetting.titleBackButtonIsHidden == false{
            self.parent?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func menuEvent(_ sender: UIButton) {
        if viewSetting.titleHomeButtonIsHidden == false{
            viewSetting.setDefault()            
            performSegue(withIdentifier: "goBackToMenu", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextLabel.text = viewSetting.titleBarText
        
        if viewSetting.titleBackButtonIsHidden == true{
            backButton.setTitle("", for: .normal)
            backButton.isHidden = true
        }
        
        if viewSetting.titleHomeButtonIsHidden == true{
            homeButton.setTitle("", for: .normal)
            homeButton.isHidden = true
        }
        
        self.view.backgroundColor = viewSetting.styleColor
        
        titleTextLabel.textColor = viewSetting.titleBarTextColor;
        backButton.setTitleColor(viewSetting.titleBarTextColor, for: .normal)
        homeButton.setTitleColor(viewSetting.titleBarTextColor, for: .normal)
        
        userLabel.text = dataService.currentUser?.name
        userLabel.textColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
