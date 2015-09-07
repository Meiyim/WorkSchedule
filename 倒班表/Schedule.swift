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
func timeZoneOffset()->Double {
    return Double(NSTimeZone.systemTimeZone().secondsFromGMT);
}
class Part: NSObject, NSCoding{
    var title = "";
    var isWork = true;
    var shouldRemind = false;
    var last: NSTimeInterval{
        get{
            return end - begin + 1;
        }
    }

    var begin: NSTimeInterval = 0
    var end: NSTimeInterval = 0
    var beginDate: NSDate = NSDate(){
        didSet{
            begin = (beginDate.timeIntervalSinceReferenceDate  ) % (3600*24.0) ;
            println("did set2");
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
    var descriptionIn24h: String{
        return String(format: "%@ ~ %@",
            begin.formattedString,end.formattedString);
    }
    init(name: String,beginDate: NSDate, endDate: NSDate, shouldRemind: Bool = false){
        title = name;
        self.beginDate = beginDate;
        self.endDate = endDate;
        self.shouldRemind = shouldRemind;
        super.init();
        begin = (beginDate.timeIntervalSinceReferenceDate) % (3600*24.0);
        end = (endDate.timeIntervalSinceReferenceDate) % (3600*24.0)
        println("did set1");
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
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        isWork = aDecoder.decodeBoolForKey("isWork")
        shouldRemind = aDecoder.decodeBoolForKey("shouldRemind");
        begin = aDecoder.decodeDoubleForKey("begin");
        end = aDecoder.decodeDoubleForKey("end");
        beginDate = NSDate(timeIntervalSinceReferenceDate: begin); //all in GMT timeZone
        endDate = NSDate(timeIntervalSinceReferenceDate: end);
        super.init();
    }

}


class Day{
    var parts = [Part]();
    weak var yesterday: Day?;
    var tail: NSTimeInterval?{
        get{
            if let iterval = parts.last?.end  {
                if iterval > 3600 * 24 {
                    return iterval - 3600*24;
                }
            }
            return nil;
        }
    };
    func isWorkConflict(thiswork: Part) -> Bool{
        for work in parts{
            if work.isConflictWithWork(thiswork) {
                return true;
            }
        }
        if(thiswork.end < yesterday?.tail || thiswork.begin < yesterday?.tail){
            return true;
        }
        return false;
    }
    func addWork(work: Part)->Int{
        if let  id = positionBeforeIndexForWork(work){
            parts.insert(work, atIndex: id);
            return id;
        }else{
            assert(false, "never should come here");
            return 0;
        }
    }
    func removeWorkatIndex(id: Int){
        parts.removeAtIndex(id);
    }
    func positionBeforeIndexForWork(work: Part) -> Int?{
        if isWorkConflict(work){
            return nil;
        }else{
            for (var i: Int = 0 ;i != parts.count; ++i) {
                if parts[i].begin > work.end {
                    return i;
                }
            }
            return 0;
        }
    }
}

class Schedule {
    var title = "";
    private var days = [Day]();
    var lastDays: Int {
        get{
            return days.count;
        }
    }
    init(){
        //days.append(Day());
    }
    func workForIndexPath(indexPath: NSIndexPath) -> Part{
       return days[indexPath.section].parts[indexPath.row];
    }
    func isWorkConflictWithIndexPath(indexPath: NSIndexPath, work: Part) -> Bool{
        return days[indexPath.section].isWorkConflict(work);
    }
    func addEmptyDay(id: Int){
        let dayToInsert = Day();
        if  id != 0 {
            dayToInsert.yesterday = days[id-1];
        }
        if(id != days.count ){
            days[id].yesterday = dayToInsert;
        }
        days.insert(dayToInsert, atIndex: id);
    }
    func removeEmptyDay(day: Int){
        assert(days[day].parts.isEmpty, "must ensure removing a emptyDay")
        if day !=  days.count - 1{
            if day == 0 {
                days[1].yesterday = nil;
            }else{
                days[day+1].yesterday = days[day-1];
            }
        }
        days.removeAtIndex(day);
    }
    func positionForWork(work: Part, forIndex indexPath: NSIndexPath) -> NSIndexPath?{
        if let row = days[indexPath.section].positionBeforeIndexForWork(work){
            return NSIndexPath(forRow: row, inSection: indexPath.section)
        }
        return nil;
    }
    func appendWork(work: Part) -> NSIndexPath?{
        /* commant out temporally
        if(days.last != nil && !days.last!.isWorkConflict(work) ){
            //insert at last day
            let insertedRow = days.last?.addWork(work);
            let insertedSection = days.count - 1;
            let insertedIndex = NSIndexPath(forRow: insertedRow!, inSection: insertedSection)
            return insertedIndex;
        }*/
        //append in the new day;
        addEmptyDay(days.count);
        days.last?.addWork(work);
        println("inserted new days at the end");
        return nil;
    }
    func addWork(work: Part, inIndex day: NSIndexPath)->NSIndexPath?{
        let row =  days[day.section].addWork(work);
        return NSIndexPath(forRow: row, inSection: day.section);
    }
    func removeWork(inIndex: NSIndexPath)->Bool{ // the return value indicated if a section is needed to be deleted too.
        let day = inIndex.section;
        let workIndex = inIndex.row;
        days[day].removeWorkatIndex(workIndex);
        if days[day].parts.isEmpty{
            removeEmptyDay(day);
            return true;
        }
        return false;
    }
    func numberOfWorksInDay(day: Int)->Int{
        return days[day].parts.count;
    }
    
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
