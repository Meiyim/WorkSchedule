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


var PAI: CGFloat = 3.1415926
func degree2Rad(deg: CGFloat) -> CGFloat{
    return deg * PAI / 180
}
func documentDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) 
    return paths[0]
}
func dataFilePath()->String {
    return documentDirectory()+"/Schedules.plist"
}
func timeZoneOffset()->Double {
    return Double(NSTimeZone.systemTimeZone().secondsFromGMT);
}
extension NSTimeInterval {
    var formattedString: String{
        
        assert(self < 3600*24*2 && self >= 0, "Time Interval should less than 24h")
        var time = self;
        if time > 3600*24 {time -= 3600*24.0}
        let h: Int = Int(time / 3600);
        let min: Int = Int(time % 3600 / 60);
        let str = String(format: "%2d : %02d", h, min)
        return str;
    }
}

func arrayCopy< T where T: NSObject, T: NSMutableCopying >(arr: Array<T> ) -> Array<T> { //一个泛型的数组复制函数。实现对容器元素的逐一深拷贝。要求元素满足NSMutableCopying协议。
    var ret = Array<T>()
    for e in arr {
        ret.append(e.mutableCopy() as! T);
    }
    return ret;
}

func doAfterDelay(seconds: Double, closure: ()->()){ // GCD framework!
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)));
    dispatch_after(when, dispatch_get_main_queue(), closure);
}