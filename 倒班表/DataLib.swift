//
//  DataLib.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/14.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation

class DataLib: NSObject, NSCoding {
    var worksLib = [Part]();
    var scheduleLib = [Schedule]();
    weak var scheduleNowApplying: Schedule?
    override init(){}
    // save&load
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(worksLib, forKey: "worksLib")
        aCoder.encodeObject(scheduleLib, forKey: "scheduleLib")
        if let _sched = scheduleNowApplying {
            let nowUsingIndex = find(scheduleLib, _sched )
            aCoder.encodeInteger(nowUsingIndex!, forKey: "nowUsingIndex")
        }else{
            aCoder.encodeInteger(-1, forKey: "nowUsingIndex")
        }
    }
    required init(coder aDecoder: NSCoder) {
        worksLib = aDecoder.decodeObjectForKey("worksLib") as! [Part]
        scheduleLib = aDecoder.decodeObjectForKey("scheduleLib") as! [Schedule]
        let id = aDecoder.decodeIntegerForKey("nowUsingIndex")
        if id == -1{
            scheduleNowApplying = nil;
        }else{
            scheduleNowApplying = scheduleLib[id];
        }
        super.init();
    }

}
