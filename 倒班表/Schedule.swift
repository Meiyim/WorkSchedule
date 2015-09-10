//
//  Schedule.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
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
class TemperalPart: Part{
    override init() {
        super.init();
        end = 88888888;
        begin = 88888888;
    }
    required init(coder aDecoder: NSCoder) {
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
        
    }
    override var last: NSTimeInterval{
        get{
            return lastValue;
        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init();
        end = 88888888;
        begin = 88888888;
    }
}
class Schedule {
    class Day{
        var parts = [Part]();
        weak var yesterday: Day?;
        var tail: NSTimeInterval?{
            get{if let iterval = parts.last?.end  {
                    if iterval > 3600 * 24 {return iterval - 3600*24;}
                }
                return nil;
            }
        };
        var intervals = [NSTimeInterval]();
        var isTemperaDay = false
        init(isTempera: Bool = false){
            if isTempera {
                self.isTemperaDay = true;
                parts.append(TemperalPart());
            }
        }
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
        func addWork(work: Part)->Int{ //the return value of this method indicate the row of the new inserted work;
            if isTemperaDay {
                assert(parts.count == 1,"shouldnt involk this on a empty day")
                parts.removeAll(keepCapacity: true)
                parts.append(work)
                isTemperaDay = false
                return 0;
            }else{
                if let  id = positionBeforeIndexForWork(work){
                    parts.insert(work, atIndex: id);
                    return id;
                }else{
                    assert(false, "never should come here"); // the new added work conflict with this day
                    return 0;
                }
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
            return parts.count
        }
    }
        private func checkNumberOfIntervals(){
            assert( !parts.isEmpty, "cannot envoke this method on a empty day")
            let threshHold = 10 * 60.0; // threshHold used to distingush different part; now it is 10 min;
            intervals.removeAll(keepCapacity: true);
            var lastEnd: NSTimeInterval! = yesterday?.tail;
            if lastEnd == nil {lastEnd = 60.0};
            for(var i = 0; i != self.parts.count ; ++i){
                if(parts[i].begin > lastEnd + threshHold){
                    intervals.append(parts[i].begin - lastEnd + 60.0); //加60秒钟是为了防止出现两班之间间隔为6:59这种情况。因为part中的end和begin在秒级的位置上不准确
                    lastEnd = parts[i].end;
                }
                intervals.append(-1.0 * Double(i)); //if negative intervals intervals the index of part in parts;
            }
            if parts.last?.end < 3600 * 24 - threshHold {
                intervals.append(3600*24.0 - parts.last!.end + 60.0);
            }
            
        }
    }


    var title = "";
    var isInEdittingMode = false{
        didSet{
            if isInEdittingMode == false {
                for day in days{
                    day.checkNumberOfIntervals();
                }
            }
        }
    };
    private var days = [Day]();
    
    init(){
        //days.append(Day());
    }
    //MARK: - querry method
    func sectionOfTemperalDays() -> Int? {
        for (var i = 0; i != days.count; ++i){
            if days[i].isTemperaDay {return i}
        }
        return nil;
    }
    func workForIndexPath(indexPath: NSIndexPath) -> Part{
        let day = days[indexPath.section]
        if isInEdittingMode{
            return day.parts[indexPath.row];
        }else{
            let interval = day.intervals[indexPath.row]
            if interval < 0.1{
                return day.parts[Int(-interval)]; //indicating a work
            }else{
                return BreakPart(last: interval); // indicating a break;
            }
            
        }
    }
    func indexPathOfIntervals() -> [NSIndexPath]{ // return the position of intervals in ANY mode. help to delete extra rows in editing mode;
        var ret = [NSIndexPath]();
        for day in 0 ..< lastDays {
            let thisDay = days[day]
            for part in 0 ..< thisDay.intervals.count{
                if thisDay.intervals[part] > 0.1 {
                    ret.append(NSIndexPath(forRow: part, inSection: day))
                }
            }
        }
        return ret;
    }
    func numberOfWorksInDay(day: Int)->Int{
        if isInEdittingMode{
            return days[day].parts.count;
        }else{
            return days[day].intervals.count;
        }
    }
    var lastDays: Int {
        get{return days.count;}
    }
    //MARK: - addNew Method --- this method can be used in display mode;
    func addEmptyDay(id: Int){
        let dayToInsert = Day(isTempera: true);
        if  id != 0 {
            dayToInsert.yesterday = days[id-1];
        }
        if(id != days.count ){
            days[id].yesterday = dayToInsert;
        }
        days.insert(dayToInsert, atIndex: id);
    }
    func appendWork(work: Part) -> NSIndexPath?{ //always append at last in a new day
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
        days.last?.checkNumberOfIntervals();
        println("inserted new days at the end");
        return nil;
    }
    //MARK: - edit method----this mothod must be used in editting mode!
    /*
    func isWorkConflictWithIndexPath(indexPath: NSIndexPath, work: Part) -> Bool{
        assert(isInEdittingMode, "this method must be envoked in Editting mode!");
        return days[indexPath.section].isWorkConflict(work);
    }*/
    func positionForWork(work: Part, forIndex indexPath: NSIndexPath) -> NSIndexPath?{
        if let row = days[indexPath.section].positionBeforeIndexForWork(work){
            return NSIndexPath(forRow: row, inSection: indexPath.section)
        }
        return nil;
    }

    func removeEmptyDay(day: Int){
        assert(isInEdittingMode, "this method must be envoked in Editting mode!");
        assert(days[day].parts.isEmpty || days[day].isTemperaDay, "must ensure removing a emptyDay or a temperal day")
        if day !=  days.count - 1{
            if day == 0 {
                days[1].yesterday = nil;
            }else{
                days[day+1].yesterday = days[day-1];
            }
        }
        days.removeAtIndex(day);
    }


    func addWork(work: Part, inIndex day: NSIndexPath)->NSIndexPath?{
        assert(isInEdittingMode, "this method must be invoked in Editting mode!");
        let row =  days[day.section].addWork(work);
        return NSIndexPath(forRow: row, inSection: day.section);
    }
    func removeWork(inIndex: NSIndexPath, closuer: (()->())? = nil)->Bool{ // the return value indicated if a section is needed to be deleted too.
        let day = inIndex.section;
        let workIndex = inIndex.row;
        days[day].removeWorkatIndex(workIndex);
        println("work:\(workIndex) removed at day:\(day)");
        if days[day].parts.isEmpty || days[0].isTemperaDay {
            closuer?();
            removeEmptyDay(day);
            return true;
        }
        return false;
    }
    //MARK: - utilities

    
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
