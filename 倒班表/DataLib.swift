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
    var scheduleParsor = ScheduleParsor();
    weak var scheduleNowApplying: Schedule? //pointer like
    override init(){}
    // save&load
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(worksLib, forKey: "worksLib")
        aCoder.encodeObject(scheduleLib, forKey: "scheduleLib")
        aCoder.encodeObject(scheduleParsor, forKey: "scheduleParsor")
        if let _sched = scheduleNowApplying {
            let nowUsingIndex = find(scheduleLib, _sched )
            aCoder.encodeInteger(nowUsingIndex!, forKey: "nowUsingIndex")
        }else{
            aCoder.encodeInteger(-1, forKey: "nowUsingIndex")
        }
    }
    required init(coder aDecoder: NSCoder) {
        if let lib = aDecoder.decodeObjectForKey("worksLib") as? [Part]{
            worksLib = lib;
        }
        if let lib = aDecoder.decodeObjectForKey("scheduleLib") as? [Schedule] {
            scheduleLib = lib
        }
        if let parsor = aDecoder.decodeObjectForKey("scheduleParsor") as? ScheduleParsor {
            scheduleParsor = parsor;
        }
        let id = aDecoder.decodeIntegerForKey("nowUsingIndex")
        if id == -1{
            scheduleNowApplying = nil;
        }else{
            scheduleNowApplying = scheduleLib[id];
        }
        super.init();
    }

}
