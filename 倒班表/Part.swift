//
//  Part.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/14.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
import UIKit
class Part: NSObject, NSCoding, NSMutableCopying{
    var title = "";
    var isWork = true;
    var shouldRemind = false;
    var begin: NSTimeInterval = 0
    var end: NSTimeInterval = 0
    var beginDate: NSDate = NSDate(){
        didSet{
            begin = (beginDate.timeIntervalSinceReferenceDate  ) % (3600*24.0) ;
        }
    };
    var endDate: NSDate = NSDate(){
        didSet{
            end = (endDate.timeIntervalSinceReferenceDate   ) % (3600*24.0) ;
            if end < begin {
                end += 3600 * 24;
            }
        }
    };
    
    
    var last: NSTimeInterval{
        get{
            return end - begin + 1;
        }
    }
    var color: UIColor = UIColor.grayColor(); //default color for part including breakPart
    var descriptionIn24h: String{
        return String(format: "%@ ~ %@",
            begin.formattedString,end.formattedString);
    }
    override init(){
        super.init();
    }
    init(name: String,beginDate: NSDate, endDate: NSDate, shouldRemind: Bool = false){
        title = name;
        self.beginDate = beginDate;
        self.endDate = endDate;
        self.shouldRemind = shouldRemind;
        super.init();
        begin = (beginDate.timeIntervalSinceReferenceDate) % (3600*24.0);
        end = (endDate.timeIntervalSinceReferenceDate) % (3600*24.0)
        print("did set1");
        if end < begin {
            end += 24 * 3600;
        }
    }
    func isConflictWithWork(work: Part)->Bool {
        if(self.end < work.begin || self.begin > work.end){
            return false;
        }
        return true;
    }
    //MARK: - NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeBool(isWork, forKey: "isWork")
        aCoder.encodeBool(shouldRemind, forKey: "shouldRemind")
        //aCoder.encodeObject(beginDate, forKey: "beginDate")
        //aCoder.encodeObject(endDate, forKey: "endDate")
        aCoder.encodeDouble(begin, forKey: "begin"); // only save time intervals!
        aCoder.encodeDouble(end, forKey: "end");
    }
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        isWork = aDecoder.decodeBoolForKey("isWork")
        shouldRemind = aDecoder.decodeBoolForKey("shouldRemind");
        begin = aDecoder.decodeDoubleForKey("begin");
        end = aDecoder.decodeDoubleForKey("end");
        beginDate = NSDate(timeIntervalSinceReferenceDate: begin); //all in GMT timeZone
        endDate = NSDate(timeIntervalSinceReferenceDate: end);
        super.init();
    }
    //MAKR: - NSMutableCopying
    func mutableCopyWithZone(zone: NSZone) -> AnyObject {
        let ret = Part()
        ret.title = self.title;
        ret.isWork = self.isWork;
        ret.shouldRemind = self.shouldRemind;
        ret.begin = self.begin;
        ret.beginDate = self.beginDate;
        ret.end = self.end
        ret.endDate  = self.endDate;
        return ret;
    }
    
}
class TemperalPart: Part{
    override init() {
        super.init();
        end = 88888888;
        begin = 88888888;
    }
    required init?(coder aDecoder: NSCoder) {
        super.init();
        end = 88888888;
        begin = 88888888;
    }
}
class BreakPart: Part{
    var lastValue: NSTimeInterval = 0.0;
    init(last: Double){
        super.init();
        end = 88888888;
        begin = 88888888;
        lastValue = last;
        isWork = false
    }
    override var last: NSTimeInterval{
        get{
            return lastValue;
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init();
        end = 88888888;
        begin = 88888888;
    }
}