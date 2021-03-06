//
//  AppDelegate.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/18.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataLib: DataLib!; //this is the only datalib in this application

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print(documentDirectory());
        dataLib = load();
        let tabBarController = window!.rootViewController as! UITabBarController;
        if let tabBarVCs = tabBarController.viewControllers{
            let navigationCont = tabBarVCs[2] as! UINavigationController;
            let schedulesVC = navigationCont.viewControllers[0] as! SchedulesVC
            schedulesVC.dataLib = self.dataLib;
            let navigationCont2 = tabBarVCs[0] as! UINavigationController
            let nowvc = navigationCont2.viewControllers[0] as! NowVC
            nowvc.dataLib = dataLib;
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        save(dataLib)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        save(dataLib)
    }
    // MARK: - load & save
    func save(lib: DataLib){
        let worksLibData = NSMutableData();
        let archiver = NSKeyedArchiver(forWritingWithMutableData: worksLibData)
        archiver.encodeObject(lib, forKey: "dataLib")
        archiver.finishEncoding();
        worksLibData.writeToFile(dataFilePath(), atomically: true);
        print("SAVE SUCCESSFULLY")
    }
    
    func load()->DataLib{
        var ret: DataLib!
        let path = dataFilePath();
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                ret = unarchiver.decodeObjectForKey("dataLib") as! DataLib;
                unarchiver.finishDecoding();
                print("LOAD SUCCESSFULLY")
            }
        }else{
            ret = DataLib();
        }
        ret.scheduleParsor.schedule?.isInEdittingMode = false; // to trigger the interval calculation
        return ret;
    }

}

