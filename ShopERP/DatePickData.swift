//
//  DatePickData.swift
//  ShopERP
//
//  Created by 洛可 on 2017/8/8.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation

class DatePickData{
    
    func getDayDataCount(nowMonth: Int, nowYear: Int) -> Int{
        switch nowMonth {
        case 1,3,5,7,8,10,12:
            return 31
        case 4,6,9,11:
            return 30
        case 2:
            if nowYear%400 == 0 || (nowYear%4 == 0 && nowYear%100 != 0){
                return 29
            }else{
                return 28
            }
        default:
            return 0
        }
    }
    
    func createDayData(max:Int, dayData: inout [Int]){
        dayData.removeAll()
        for index in 1...max{
            dayData.append(index)
        }
    }
}
