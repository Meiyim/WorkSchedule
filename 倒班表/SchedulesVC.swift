//
//  SchedulesVC.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

class SchedulesVC: UITableViewController {
    // MARK: - properties
    weak var dataLib: DataLib!;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1;
        }else{
            return dataLib.scheduleLib.count;
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "工作库"; //i18n
        }else{
            return "倒班表";
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell;
        if indexPath.row == 0 && indexPath.section == 0 {
            if let cell2 = tableView.dequeueReusableCellWithIdentifier("WorkManagementCell"){
                cell = cell2;
            }else{
                cell = UITableViewCell(style: .Default, reuseIdentifier: "WorkManagementCell")
            }
            cell.textLabel?.text = "管理工作库" //i18n
            cell.accessoryType  = .DisclosureIndicator
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell")!
            let sched = dataLib.scheduleLib[indexPath.row]
            cell.textLabel?.text = sched.title;
            cell.detailTextLabel?.text = sched.displaySummery;
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegueWithIdentifier("ShowWorkManagement", sender: tableView.cellForRowAtIndexPath(indexPath))
        }else{
            performSegueWithIdentifier("ShowNewSchedule", sender: indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    // MARK: - utilities
    private func applySchedule(schedule: Schedule?){ // will set the cell at 1-0 to tint color
        dataLib.scheduleNowApplying = schedule;
        let id = NSIndexPath(forRow: 0, inSection: 1)
        if schedule == nil {
            if let cell = tableView.cellForRowAtIndexPath(id){
                cell.textLabel?.textColor = UIColor.blackColor(); //set to normal
                cell.accessoryType = .None;
            }
        }else{
            let cell = tableView.cellForRowAtIndexPath(id)! //should always succeed
            cell.textLabel?.textColor = cell.textLabel?.tintColor;
            cell.accessoryType = .Checkmark
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWorkManagement" {
            let controller = segue.destinationViewController as! WorkManagementVC
            controller.dataLib = self.dataLib;
        } else if segue.identifier == "ShowNewSchedule" {
            let navi = segue.destinationViewController as! UINavigationController;
            let controller = navi.topViewController as! ScheduleManagementVC
            if let id = sender as? NSIndexPath{ //editting a schedule
                controller.dataLib = dataLib;
                controller.scheduleToEdit = dataLib.scheduleLib[id.row];
                controller.delegate = self;
            }else{
                controller.dataLib = dataLib; // create a new schedule
                let schedule = Schedule();
                controller.scheduleToEdit = schedule;
                controller.delegate = self;
            }
        }
    }
    

}


extension SchedulesVC: ScheduleManagemenVCDelegate {
    func scheduleManagementVC(commitChange schedule: Schedule,completion closure: (()->())?) {
        doAfterDelay(0.3){
            var idtodelete: NSIndexPath?;
            if let id = self.dataLib.scheduleLib.indexOf(schedule){
                self.dataLib.scheduleLib.removeAtIndex(id);
                idtodelete = NSIndexPath(forRow: id, inSection: 1)
                //self.tableView.deleteRowsAtIndexPaths([idtodelete!], withRowAnimation: .Right)
            }

            var idtoinsert: NSIndexPath!
            if self.dataLib.scheduleNowApplying == nil {
                self.dataLib.scheduleLib.insert(schedule, atIndex: 0); // if no schedule is now applying;
                idtoinsert = NSIndexPath(forRow: 0, inSection: 1)
            }else{
                self.dataLib.scheduleLib.insert(schedule, atIndex: 1);
                idtoinsert = NSIndexPath(forRow: 1, inSection: 1);
            }
            self.tableView.beginUpdates()
            if let id = idtodelete {
                self.tableView.deleteRowsAtIndexPaths([id], withRowAnimation: .Right)
            }
            self.tableView.insertRowsAtIndexPaths([idtoinsert], withRowAnimation: .Right) // always insert at the head
            self.tableView.endUpdates();
            closure?();
        }
    }
    func scheduleManagementVC(deleteSchedule schedule: Schedule){

        doAfterDelay(0.3){
            if let id = self.dataLib.scheduleLib.indexOf(schedule){
                self.dataLib.scheduleLib.removeAtIndex(id);
                let idtodelete = NSIndexPath(forRow: id, inSection: 1)
                self.tableView.deleteRowsAtIndexPaths([idtodelete], withRowAnimation: .Fade);
                if schedule == self.dataLib.scheduleNowApplying {
                    self.applySchedule(nil);
                }
            }
        }

    }
    func scheduleManagementVC(scheduleApplied schedule: Schedule){
        applySchedule(nil);
        scheduleManagementVC(commitChange: schedule, completion:{self.applySchedule(schedule)});
    }
    func scheduleManagementVC(cancelSchedule schedule: Schedule, retreatToSchedule ori: Schedule){
        if let id = dataLib.scheduleLib.indexOf(schedule){
            dataLib.scheduleLib[id] = ori;
        }
    }

}
