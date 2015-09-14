//
//  DataLib.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/14.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
class WorksLib {
    var lib = [Part]()
}

class DataLib {
    var worksLib = WorksLib();
    var scheduleLib = [Schedule]();
    func save(){
        let worksLibData = NSMutableData();
        let archiver = NSKeyedArchiver(forWritingWithMutableData: worksLibData)
        archiver.encodeObject(worksLib.lib, forKey: "WorksLib")
        archiver.encodeObject(scheduleLib, forKey: "ScheduleLib");
        archiver.finishEncoding();
        worksLibData.writeToFile(dataFilePath(), atomically: true);
    
    }
    
    func load(){
        let path = dataFilePath();
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                if let works = unarchiver.decodeObjectForKey("WorksLib") as? [Part]{
                    worksLib.lib = works
                }
                if let data1 = unarchiver.decodeObjectForKey("ScheduleLib") as? [Schedule]{
                    scheduleLib = data1
                }
                unarchiver.finishDecoding();
            }
        }
    }
}
