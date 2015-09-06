//
//  WorkManagementVC.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/20.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

class WorkManagementVC: UITableViewController {
    //MARK: - properties
    var works: WorksLib!;
    lazy var formatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateStyle = .NoStyle
        ret.timeStyle = .ShortStyle;
        return ret;}()
    
    //MARKS: - VCs
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        works.append(Part(name: "Day", beginDate: NSDate(timeIntervalSinceReferenceDate: 10), endDate: NSDate(timeIntervalSinceReferenceDate: 400)));
        works.append(Part(name: "Night", beginDate: NSDate(timeIntervalSinceReferenceDate: 10000), endDate: NSDate(timeIntervalSinceReferenceDate: 10400)));*/
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    required init (coder aDecoder: NSCoder){
        super.init(coder: aDecoder)    
    }
    // MARK: - utilities


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return works.lib.count;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowEditWork", sender: indexPath)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = works.lib[indexPath.row].title;
        let work = works.lib[indexPath.row];
        cell.detailTextLabel!.text = String(format: "%@ ~ %@",
                                            work.begin.formattedString,work.end.formattedString )
        return cell
    }
    


    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            works.lib.removeAtIndex(indexPath.row);
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    






    
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNewWork" {
            let dest = segue.destinationViewController as! UINavigationController;
            let cont = dest.topViewController as! NewWorkVC;
            cont.delegate = self
        }else if segue.identifier == "ShowEditWork" {
            let dest = segue.destinationViewController as! UINavigationController;
            let cont = dest.topViewController as! NewWorkVC;
            cont.delegate = self
            let id = sender as! NSIndexPath;
            cont.workToEdit = works.lib[id.row];
        }
        super.prepareForSegue(segue, sender: sender)
    }
    

}


extension WorkManagementVC: NewWorkVCDelegate{
    func appendNewWork(work: Part) {
        works.lib.append(work)
        tableView.reloadData();
        println("work inserted!")
    }
    func editWork(work: Part) {
        if let id = find(works.lib, work){
            works.lib[id] = work;
            tableView.reloadData();
            println("work modified! \(work)");
        }else{
            assert(false, "never should come here")
        }
    }
}