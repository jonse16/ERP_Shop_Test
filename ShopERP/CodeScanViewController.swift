//
//  CodeScanViewController.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/18.
//  Copyright © 2017年 roko. All rights reserved.
//

import UIKit
import AVFoundation

class CodeScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var dataService = DataService.sharedInstance()
    var message = Message.sharedInstance()
    var timer:Timer!
    var viewSetting = ViewSetting.sharedInstance()
    
    var scanRectView:UIView!
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var session:AVCaptureSession!
    var preview:AVCaptureVideoPreviewLayer!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        transitionCamera()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromCamera()
    }
    
    func fromCamera(){
        do{
            device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            input = try AVCaptureDeviceInput(device: device)
            output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            
            
            session = AVCaptureSession()
            if UIScreen.main.bounds.size.height<500 {
                session.sessionPreset = AVCaptureSessionPreset640x480
            }else{
                session.sessionPreset = AVCaptureSessionPresetHigh
            }
            session.addInput(input)
            session.addOutput(output)
            
            output.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypeEAN8Code,
                                          AVMetadataObjectTypeCode128Code,
                                          AVMetadataObjectTypeCode39Code,
                                          AVMetadataObjectTypeCode93Code]
            
            //计算中间可探测区域
            let windowSize = UIScreen.main.bounds.size;
            let scanSize = CGSize(width:windowSize.width*1/2,
                                  height:windowSize.width*1/2)
            var scanRect = CGRect(x:(windowSize.width-scanSize.width)/2,
                                  y:(windowSize.height-scanSize.height)/2,
                                  width:scanSize.width,
                                  height:scanSize.height)
            
            //计算rectOfInterest 注意x,y交换位置
            scanRect = CGRect(x:scanRect.origin.y/windowSize.height,
                              y:scanRect.origin.x/windowSize.width,
                              width:scanRect.size.height/windowSize.height,
                              height:scanRect.size.width/windowSize.width)
            
            //设置可探测区域
            self.output.rectOfInterest = scanRect
            self.preview = AVCaptureVideoPreviewLayer(session:self.session)
            self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.preview.frame = UIScreen.main.bounds

            transitionCamera()
            self.view.layer.insertSublayer(self.preview, at:0)
            
            //添加中间的探测区域绿框
            self.scanRectView = UIView();
            self.view.addSubview(self.scanRectView)
            self.scanRectView.frame = CGRect(x:0, y:0, width:scanSize.width,
                                             height:scanSize.height)
            self.scanRectView.center = CGPoint(x:UIScreen.main.bounds.midX,
                                               y:UIScreen.main.bounds.midY)
            self.scanRectView.layer.borderColor = UIColor.green.cgColor
            self.scanRectView.layer.borderWidth = 1
            
            
            let backButton = UIButton(frame: CGRect(x: 0, y: 20, width: 160, height: 20))
            backButton.setTitle("返回", for: .normal)
            backButton.addTarget(self, action: #selector(CodeScanViewController.backToOrder), for: .touchUpInside)
            self.view.addSubview(backButton)
            
            let keyButton = UIButton(frame: CGRect(x: 0, y:100, width: 160, height: 20))
            keyButton.setTitle("手動輸入", for: .normal)
            keyButton.addTarget(self, action: #selector(CodeScanViewController.keyCode), for: .touchUpInside)
            self.view.addSubview(keyButton)
            
            //开始捕获
            self.session.startRunning()
            
            //放大
            do {
                try self.device!.lockForConfiguration()
            } catch _ {
                NSLog("Error: lockForConfiguration.");
            }
            self.device!.videoZoomFactor = 1.5
            self.device!.unlockForConfiguration()
        }catch{
            //打印错误消息
            let alertController =
                UIAlertController(title: "提醒",
                                  message: "請在iPhone的\"設定-隱私-相機\"選項中,允许APP使用您的相機",
                                  preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func transitionCamera(){
        if let videoPreviewLayerConnection = self.preview.connection {
            switch UIDevice.current.orientation {
            case .landscapeLeft, .portrait:
                print("landscapeLeft")
                videoPreviewLayerConnection.videoOrientation = .landscapeRight
            case .landscapeRight, .portraitUpsideDown:
                print("landscapeRight")
                videoPreviewLayerConnection.videoOrientation = .landscapeLeft
            case .unknown:
                print("unknown")
            default:
                break;
            }
        }
    }
    
    func backToOrder(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyCode(){
        self.session.stopRunning()
        let alert = UIAlertController(title: "手動輸入條碼", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "請輸入條碼內容"
            textfield.keyboardType = UIKeyboardType.numberPad
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            if let inputText = alert.textFields?[0].text{
                if inputText != ""{
                    self.findProductByCode(value: inputText)
                }else{
                    self.message.popAlert(title: "參數有誤", message: "條碼內容不可為空值", uiViewController: self)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            (action) in
            self.session.startRunning()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    //摄像头捕获
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        self.scanRectView.layer.borderColor = UIColor.red.cgColor
        
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0]
                as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            
            if stringValue != nil{
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()
        findProductByCode(value: stringValue!)
        
        //        let alertController = UIAlertController(title: "QRCode",
        //                                                message: stringValue,preferredStyle: .alert)
        //        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
        //            action in
        //            //繼續掃描
        //            self.session.startRunning()
        //        })
        //        alertController.addAction(okAction)
        //        self.present(alertController, animated: true, completion: nil)
    }
    
    func findProductByCode(value:String){
        //find product
        //openmask
        dataService.findProduct(by: "barcode", value: value)
        self.checkFindProductByCodeFinishCount = 0
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.checkFindProductByCodeFinish),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    var checkFindProductByCodeFinishCount = 0
    
    func checkFindProductByCodeFinish(){
        if checkFindProductByCodeFinishCount == 20{
            timer.invalidate()
            message.popAlert(title: "網路錯誤", message: "連線逾時 請檢查網路 or 重新執行 ",uiViewController: self)
            //            self.closeMask()
            return;
        }else {
            if dataService.loadIngFindProductByCode == false{
                timer.invalidate()
                if dataService.orderProductResult.count == 0{
                    let alertController = UIAlertController(title: "掃描結果",
                                                            message: "沒有找到相符的資料",
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "確定", style: .default, handler: {
                        action in
                        //繼續掃描
                        self.scanRectView.layer.borderColor = UIColor.green.cgColor
                        self.session.startRunning()
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    performSegue(withIdentifier: "goToOrderProductResult", sender: nil)
                }
            }
        }
        checkFindProductByCodeFinishCount += 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOrderProductResult"{
            viewSetting.titleBarText = "商品清單"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
