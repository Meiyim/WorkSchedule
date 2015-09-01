//
//  Schedule.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
func documentDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    return paths[0]
}
func dataFilePath()->String {
    return documentDirectory().stringByAppendingPathComponent("Schedules.plist")
}

class Part: NSObject, NSCoding{
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
    //MARK: - NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeBool(isWork, forKey: "isWork")
        aCoder.encodeBool(shouldRemind, forKey: "shouldRemind")
        aCoder.encodeObject(beginDate, forKey: "beginDate")
        aCoder.encodeObject(endDate, forKey: "endDate")
    }
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        isWork = aDecoder.decodeBoolForKey("isWork")
        shouldRemind = aDecoder.decodeBoolForKey("shouldRemind");
        beginDate = aDecoder.decodeObjectForKey("beginDate") as! NSDate;
        endDate = aDecoder.decodeObjectForKey("endDate") as! NSDate;
        begin = beginDate.timeIntervalSinceReferenceDate % (3600*24)
        end = endDate.timeIntervalSinceReferenceDate % (3600*24)
        super.init();
    }

}

class Schedule {
    var title = "";
    var parts = [Part]();
}
class WorksLib {
    var lib = [Part]()
}
class DataLib {
    var worksLib = WorksLib();
    var scheduleLib = [Schedule]();
    func save(){
        let data = NSMutableData();
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(worksLib.lib, forKey: "WorksLib")
        archiver.finishEncoding();
        data.writeToFile(dataFilePath(), atomically: true);
    }
    
    func load(){
        let path = dataFilePath();
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                let works = unarchiver.decodeObjectForKey("WorksLib") as! [Part]
                worksLib.lib = works
                unarchiver.finishDecoding();
            }
        }
    }
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
