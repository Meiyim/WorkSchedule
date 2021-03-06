//
//  sceduleParsor.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/17.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
import UIKit
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
    var dayList = [Int]();
    //MARK: - weak observer;
    weak var spinnerView: CycleSpinnerView!
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
        super.init();
        if let date = aDecoder.decodeObjectForKey("applyDate") as? NSDate{
            if let sched = aDecoder.decodeObjectForKey("schedule") as? Schedule{
                apply(sched, date: date,animated: false);
            }
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(vacations, forKey: "vacations")
        aCoder.encodeObject(applyDate, forKey: "applyDate")
        aCoder.encodeObject(schedule, forKey: "schedule");
    }
    //MARK: - settings
    func apply(sched: Schedule, date: NSDate, animated: Bool){ //argument could be nil
        schedule = sched.mutableCopy() as? Schedule;
        applyDate = calendar.startOfDayForDate(date)
        schedule?.isInEdittingMode = false
        var dayNo = 0;
        for _ in 0..<365 {
            dayList.append(dayNo);
            if(++dayNo == schedule?.lastDays){dayNo = 0}
        }
        if(animated){
            spinnerView.start();
        }
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
            let _ = tuple.0;
            let _ = tuple.1;
            break;
        }
    }
    //MARK: - query
    func dateForDayNo(day: Int) -> NSDate?{
        if !isApplying {return nil}
        return date(applyDate!, afterdays: day);
    }
    func dayNoForDate(date: NSDate) -> Int?{
        if !isApplying {return nil}
        return deferenceBetween(applyDate!, secondDate: date); //day id for scheduleParsor, not schedule!
    }
    func partNoForDate(date: NSDate) -> Int?{
        if !isApplying {return nil}
        let day = dayNoForDate(date)!
        let interval = date.timeIntervalSinceDate(midNightOfDate(date));
        return schedule!.partNOForTime(interval, inDay: dayList[day]);
    }
    func indexPathForDate(date: NSDate) -> NSIndexPath?{ //indexPath for scheduleParsor, not schedule; considere vacation
        if !isApplying {return nil}
        return NSIndexPath(forRow: partNoForDate(date)!, inSection: dayNoForDate(date)!);
    }
    func indexPathAfterIndexPath(indexPath: NSIndexPath) -> NSIndexPath{// should involked when applied
        if indexPath.row == numberOfWorksForIndexPath(indexPath)! - 1{
            return NSIndexPath(forRow: 0, inSection: indexPath.section + 1)
        }else{
            return NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section);
        }
    }
    func numberOfWorksForIndexPath(id: NSIndexPath) -> Int?{  // number of works in a day
        return schedule?.numberOfWorksInDay(dayList[ id.section])
    }
    func workForIndexPath(id: NSIndexPath) -> Part?{
        return schedule?.workForIndexPath(NSIndexPath(forRow: id.row, inSection: dayList[id.section])); // obtain data from schedule
    }
    func workForDate(date: NSDate) -> Part?{
        if let indexPath = indexPathForDate(date){
            return workForIndexPath(indexPath)
        }else{ return nil }
    }

    func nextWorkForDate(date: NSDate) -> Part?{ //
        if !isApplying {return nil}
        let id = indexPathForDate(date)
        var next = indexPathAfterIndexPath(id!)
        var part =  workForIndexPath(next)!;
        while (!part.isWork) {
            next = indexPathAfterIndexPath(next)
            part = workForIndexPath(next)!
        }
        return part;
    }
    func intervalsWithin25HFrom(date: NSDate) -> [(NSTimeInterval,UIColor)]?{
        if !isApplying {return nil;}
        var id = indexPathForDate(date)!
        var part = workForIndexPath(id)!;
        var sum = part.last
        var ret = [(NSTimeInterval,UIColor)]();
        ret.append((part.last,part.color))
        while (sum < 25 * 3600){
            id = indexPathAfterIndexPath(id)
            part = workForIndexPath(id)!
            sum += part.last
            ret.append((part.last,part.color))
        }
        return ret;
    }
    var nextKeyTime: NSDate?{ // if now break return next work begin time , if now work return work end time
        if !isApplying {return nil}
        let now = NSDate();
        let day = dayNoForDate(now)!;
        if isWorkingNow {
            let work = workForDate(now)!
            return timeIntervalToDate(work.end + 3600 * 24 * Double(day))
        }else{
            let work = nextWorkForDate(now)!
            return timeIntervalToDate(work.begin + 3600 * 24 * Double(day))
        }
    }
    var timeToNextKeyTime: NSDate? {
        if !isApplying {return nil}
        var interval = nextKeyTime!.timeIntervalSinceDate(NSDate())
        if interval < 0 { interval += 3600 * 24;}
        return timeIntervalToDate(interval);
        
        
    }
    var isWorkingNow: Bool{ //should ensure applying before involk should be top level interface
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
            var i = 0;
            for(i = dayNoForDate(NSDate())!; i != 0 ; --i){
                if dayList[i] == 0 {
                    break;
                }
            }
            let dif = NSDate().timeIntervalSinceDate( dateForDayNo(i)! );
            return dif / Double(schedule!.lastDays * 3600 * 24)
        }
    }
    func dateForSection(sec: Int) -> NSDate{
        return date(applyDate!, afterdays: sec)
    }
    //MARK: - utilities
    private func timeIntervalToDate(time: NSTimeInterval) -> NSDate{
        return applyDate!.dateByAddingTimeInterval(time);
    }
    func aYearAgoOf(date: NSDate) -> NSDate {
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        comp.year-- ;
        return calendar.dateFromComponents(comp)!;
    }
    private func midNightOfDate(date: NSDate) -> NSDate{
        return calendar.startOfDayForDate(date);
    }
    func date(date: NSDate, afterdays days: Int) -> NSDate{
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        comp.day += days;
        return calendar.dateFromComponents(comp)!;
    }
    private func deferenceBetween(firstDate: NSDate, secondDate: NSDate) -> Int {
        let sec = secondDate.timeIntervalSinceDate(firstDate)
        return Int(sec)/(3600 * 24)
    }
}