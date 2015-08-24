//
//  Schedule.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation

class Part: NSObject {
    var title = "";
    var isWork = true;
    var shouldRemind = false;
    var last: NSTimeInterval{
        get{
            var ret = end - begin + 1;
            if ret < 0 {
                ret+=(24*3600);
            }
            return ret;
        }
    }
    var begin: NSTimeInterval = 0
    var end: NSTimeInterval = 0
    var beginDate: NSDate = NSDate(){
        didSet{
            begin = beginDate.timeIntervalSinceReferenceDate % (3600*24)
        }
    };
    var endDate: NSDate = NSDate(){
        didSet{
            end = endDate.timeIntervalSinceReferenceDate % (3600*24)
        }
    };
    init(name: String,beginDate: NSDate, endDate: NSDate, shouldRemind: Bool = false){
        title = name;
        self.beginDate = beginDate;
        self.endDate = endDate;
        self.shouldRemind = shouldRemind;
        begin = beginDate.timeIntervalSinceReferenceDate % (3600*24)
        end = endDate.timeIntervalSinceReferenceDate % (3600*24)
    }

}

class Schedule {
    var title = "";
    var parts = [Part]();
}


extension NSTimeInterval {
    var formattedString: String{
        assert(self < 3600*24, "Time Interval should less than 24h")
        let h: Int = Int(self) / 3600;
        let min: Int = (Int(self) % 3600) / 60;
        let str = String(format: "%2d : %02d", h, min)
        return str;
    }
}
