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
        
    }
    func encodeWithCoder(aCoder: NSCoder) {
    }
    //MARK: - settings
    func apply(sched: Schedule, date: NSDate){
        schedule = sched;
        applyDate = date;
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
    func worksForDate(date: NSDate) -> [Part] {
        return [Part]();
    }
    var now: NSDate{
        get{
            return NSDate();
        }
    }
    var isWorkingNow: Bool{
        get{
            return true;
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
    func aYearAgoOf(date: NSDate) -> NSDate {
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        comp.year-- ;
        return calendar.dateFromComponents(comp)!;
    }
    private func midNightOfDate(date: NSDate) -> NSDate{
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        return calendar.dateFromComponents(comp)!;
    }
    private func date(date: NSDate, afterdays days: Int) -> NSDate{
        let comp = calendar.components([.Year, .Month, .Day], fromDate: date)
        comp.day += days;
        return calendar.dateFromComponents(comp)!;
    }
}