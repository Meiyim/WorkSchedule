//
//  extensions.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/6.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
import UIKit
import Dispatch
func documentDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    return paths[0]
}
func dataFilePath()->String {
    return documentDirectory().stringByAppendingPathComponent("Schedules.plist")
}
func timeZoneOffset()->Double {
    return Double(NSTimeZone.systemTimeZone().secondsFromGMT);
}
extension NSTimeInterval {
    var formattedString: String{
        
        assert(self < 3600*24*2 && self > 0, "Time Interval should less than 24h")
        var time = self;
        if time > 3600*24 {time -= 3600*24.0}
        let h: Int = Int(time / 3600);
        let min: Int = Int(time % 3600 / 60);
        let str = String(format: "%2d : %02d", h, min)
        return str;
    }
}

func doAfterDelay(seconds: Double, closure: ()->()){ // GCD framework!
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)));
    dispatch_after(when, dispatch_get_main_queue(), closure);
}