//
//  TestScrollViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/2.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit

class TestScrollViewController: UIViewController {
    
    var scView:UIScrollView!
    let buttonPadding:CGFloat = 10
    var xOffset:CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        scView = UIScrollView(frame: CGRect(x: 0, y: 120, width: view.bounds.width, height: 50))
//        view.addSubview(scView)
//        
//        scView.backgroundColor = UIColor.blue
//        scView.translatesAutoresizingMaskIntoConstraints = false
//        
//        for i in 0 ... 10 {
//            let button = UIButton()
//            button.tag = i
//            button.backgroundColor = UIColor.darkGray
//            button.setTitle("\(i)", for: .normal)
//            button.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: 70, height: 30)
//            xOffset = xOffset + CGFloat(buttonPadding) + button.frame.size.width
//            scView.addSubview(button)
//        }
//        scView.contentSize = CGSize(width: xOffset, height: scView.frame.height)
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
