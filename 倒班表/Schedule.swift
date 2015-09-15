//
//  Schedule.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation

class Schedule: NSObject, NSCoding, NSMutableCopying {
    class Day: NSObject, NSCoding, NSMutableCopying{
        var parts = [Part]();
        weak var yesterday: Day?;
        var tail: NSTimeInterval?{
            get{if let iterval = parts.last?.end  {
                    if iterval > 3600 * 24 {return iterval - 3600*24;}
                }
                return nil;
            }
        };
        //MARK: - save & loads
        required init(coder aDecoder: NSCoder) {
            parts = aDecoder.decodeObjectForKey("parts") as! [Part] //wont encode yesterday property when encoding
        }
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(parts, forKey: "parts");
        }
        //MARK: - copying
        func mutableCopyWithZone(zone: NSZone) -> AnyObject? {
            var ret = Day();
            ret.parts = arrayCopy(self.parts)
            ret.yesterday = nil;
            return ret;
        }
        //initialization
        init(isTempera: Bool = false){
            if isTempera {
                self.isTemperaDay = true;
                parts.append(TemperalPart());
            }
        }
        //MARK: - utilities
        var intervals = [NSTimeInterval]();
        var isTemperaDay = false

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
    private var days = [Day]();
    var isInEdittingMode = false{
        didSet{
            if isInEdittingMode == false {
                for i in 0..<lastDays { //clear the temperal days
                    if days[i].isTemperaDay {
                        removeEmptyDay(i);
                        break;
                    }
                }
                for day in days{
                    day.checkNumberOfIntervals();
                }

            }
        }
    };

    //MARK: - load&save
    override init(){
        //days.append(Day());
    }
    required init(coder aDecoder: NSCoder) {
        isInEdittingMode = false;
        title = aDecoder.decodeObjectForKey("title") as! String;
        days = aDecoder.decodeObjectForKey("days") as! [Day];
        for(var i: Int = 1; i != days.count ; ++i){
            days[i].yesterday = days[i-1];
        }
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(days, forKey: "days");
        aCoder.encodeObject(title, forKey: "title");
    }
    //MARK: - NSCopying
    func mutableCopyWithZone(zone: NSZone) -> AnyObject? {
        var ret = Schedule();
        ret.title = self.title
        ret.isInEdittingMode = self.isInEdittingMode
        ret.days = arrayCopy(self.days);
        for i in 1..<ret.days.count {
            ret.days[i].yesterday = ret.days[i-1] //must reConfigue the yesterday for each day in days;
        }
        return ret;
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
    //MARK: - clearAll
    func clearAll(){
        days.removeAll(keepCapacity: false);
        
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
    func positionForWork(work: Part, forIndex indexPath: NSIndexPath) -> NSIndexPath?{
        if let row = days[indexPath.section].positionBeforeIndexForWork(work){
            return NSIndexPath(forRow: row, inSection: indexPath.section)
        }
        return nil;
    }
    func removeEmptyDay(day: Int){
        //(isInEdittingMode, "this method must be envoked in Editting mode!");
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
    func removeWork(inIndex: NSIndexPath)->Bool{ // the return value indicated if a section is needed to be deleted too.
        let day = inIndex.section;
        let workIndex = inIndex.row;
        days[day].removeWorkatIndex(workIndex);
        println("work:\(workIndex) removed at day:\(day)");
        if days[day].parts.isEmpty || days[day].isTemperaDay {
            removeEmptyDay(day);
            return true;
        }
        return false;
    }
    //MARK: - utilities

    
}
