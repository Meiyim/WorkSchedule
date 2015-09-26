//
//  sceduleParsor.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/17.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
enum VacationStyle{
    case Cover
    case Delay
    case Canceled;
    case Swap( ( NSDate, NSDate ))
}
class Vacation: NSObject, NSCoding{
    var fromDate: NSDate!;
    var toDate: NSDate!;
    var style: VacationStyle;

    override init(){
        fromDate = nil; toDate = nil; style = .Canceled;
    }
    init(from: NSDate, to: NSDate, style: VacationStyle){
        fromDate = from
        toDate = to;
        self.style = style;
    }
    required init?(coder aDecoder: NSCoder) {
        fromDate = aDecoder.decodeObjectForKey("fromDate") as! NSDate;
        toDate = aDecoder.decodeObjectForKey("toDate") as! NSDate;
        let id = aDecoder.decodeIntegerForKey("style")
        switch id {
        case 0:
            style = .Cover
        case 1:
            style = .Delay
        case 2:
            let date1 = aDecoder.decodeObjectForKey("styleSwap0") as! NSDate
            let date2 = aDecoder.decodeObjectForKey("styleSwap1") as! NSDate
            style = .Swap((date1,date2))
        default:
            style = .Canceled;
            break;
        }
        
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(fromDate, forKey: "fromDate")
        aCoder.encodeObject(toDate, forKey: "toDate");
        switch style{
        case .Cover:
            aCoder.encodeInteger(0, forKey: "style")
        case .Delay:
            aCoder.encodeInteger(1, forKey: "style")
        case .Canceled:
            assert(false, "never shuold come here")
            break;
        case .Swap(let tuple):
            aCoder.encodeInteger(2, forKey: "style")
            aCoder.encodeObject(tuple.0, forKey: "styleSwap0")
            aCoder.encodeObject(tuple.0, forKey: "styleSwap1")
            
        }
    }
}
class ScheduleParsor: NSObject, NSCoding{
    //MARK: - properties
    var schedule: Schedule?
    var applyDate: NSDate?
    var vacations = [Vacation]()
    var calendar = NSCalendar(identifier: "gregorian")!
    //MARK: - initialization
    override init(){
        schedule = nil;
        applyDate = nil;
    }
    //MARK: - save & load
    required init?(coder aDecoder: NSCoder) {
        if let vac = aDecoder.decodeObjectForKey("vacations") as? [Vacation]{
            vacations = vac;
        }else{
            vacations = [Vacation]();
        }
        applyDate = aDecoder.decodeObjectForKey("applyDate") as? NSDate;
        schedule = aDecoder.decodeObjectForKey("schedule") as? Schedule;
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(vacations, forKey: "vacations")
        aCoder.encodeObject(applyDate, forKey: "applyDate")
        aCoder.encodeObject(schedule, forKey: "schedule");
    }
    //MARK: - settings
    func apply(sched: Schedule, date: NSDate){ //argument could be nil
        schedule = sched.mutableCopy() as? Schedule;
        applyDate = date;
        schedule?.isInEdittingMode = false
    }
    func clear(){
        schedule = nil;
        applyDate = nil
    }
    func setVacation(fromDate: NSDate, toDate: NSDate, style: VacationStyle){
        switch style{
        case .Cover:
            break;
        case .Delay:
            break;
        case .Canceled:
            break;
        case .Swap(let tuple):
            let swapFromDate = tuple.0;
            let swapToDate = tuple.1;
            break;
        }
    }
    //MARK: - query
    func worksIn24HForDate(date: NSDate) -> [Part] {
        return [Part]();
    }
    func dayNoForDate(date: NSDate) -> Int?{
        if !isApplying {return nil}
        return deferenceBetween(applyDate!, secondDate: date) % (schedule!.lastDays)
    }
    func partNoForDate(date: NSDate) -> Int?{
        if !isApplying {return nil}
        let day = dayNoForDate(date)!
        let interval = date.timeIntervalSinceDate(midNightOfDate(date));
        return schedule!.partNOForTime(interval, inDay: day);
    }
    func indexPathForDate(date: NSDate) -> NSIndexPath?{
        if !isApplying {return nil}
        return NSIndexPath(forRow: partNoForDate(date)!, inSection: dayNoForDate(date)!);
    }
    func workForDate(date: NSDate) -> Part?{
        if let indexPath = indexPathForDate(date){
            return schedule!.workForIndexPath(indexPath);
        }else{ return nil }
    }
    func nextWorkForDate(date: NSDate) -> Part?{ //
        if var id = partNoForDate(date){
            var day = dayNoForDate(date)!
            if ++id == schedule!.numberOfWorksInDay(day++){
                id = 0;
                if day == schedule!.lastDays{day = 0}
            }
            let indexPath = NSIndexPath(forRow: id, inSection: day);
            return schedule!.workForIndexPath(indexPath);
        }else{
            return nil;
        }
    }
    var nextKeyTime: NSDate?{ // if now break return next work begin time , if now work return next work end time
        if !isApplying {return nil}
        if isWorkingNow {
            let work = workForDate(NSDate())
            let comp = NSDateComponents()
            comp.second = Int(work!.end)
            return calendar.dateFromComponents(comp)
        }else{
            let work = nextWorkForDate(NSDate())
            return timeIntervalToDate(work!.begin)
        }
    }
    var timeToNextKeyTime: NSDate? {
        if !isApplying {return nil}
        let interval = nextKeyTime!.timeIntervalSinceDate(NSDate())
        return timeIntervalToDate(interval);
        
        
    }
    var isWorkingNow: Bool{ //shoudl ensure applying before involk should be top level interface
        get{
            if let part = workForDate(NSDate()){
                return part.isWork
            }else{
                return false; // not applying
            }
        }
    }
    var isApplying: Bool{
        get{
            if schedule == nil || applyDate == nil {
                return false;
            }else{
                return true;
            }
        }
    }
    var progressInWork: Double{
        get{
            return 0.0;
        }
    }
    var progressInCycle: Double{
        get{
            return 0.0;
        }
    }
    //MARK: - utilities
    private func timeIntervalToDate(time: NSTimeInterval) -> NSDate{
        let comp = NSDateComponents()
        comp.second = Int(time)
        return calendar.dateFromComponents(comp)!
    }
    func aYearAgoOf(date: NSDate) -> NSDate {
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        comp.year-- ;
        return calendar.dateFromComponents(comp)!;
    }
    private func midNightOfDate(date: NSDate) -> NSDate{
        return calendar.startOfDayForDate(date);
    }
    private func date(date: NSDate, afterdays days: Int) -> NSDate{
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        comp.day += days;
        return calendar.dateFromComponents(comp)!;
    }
    private func deferenceBetween(firstDate: NSDate, secondDate: NSDate) -> Int {
        let sec = secondDate.timeIntervalSinceDate(firstDate)
        return Int(sec)/(3600 * 24)
    }
}