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
    var works = [Part]();
    lazy var formatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateStyle = .NoStyle
        ret.timeStyle = .ShortStyle;
        return ret;}()
    override func viewDidLoad() {
        super.viewDidLoad()
        works.append(Part(name: "Day", beginDate: NSDate(timeIntervalSinceReferenceDate: 10), endDate: NSDate(timeIntervalSinceReferenceDate: 400)));
        works.append(Part(name: "Night", beginDate: NSDate(timeIntervalSinceReferenceDate: 10000), endDate: NSDate(timeIntervalSinceReferenceDate: 10400)));        // Uncomment the following line to preserve selection between presentations
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
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return works.count;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowEditWork", sender: indexPath)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = works[indexPath.row].title;
        let work = works[indexPath.row];
        cell.detailTextLabel!.text = String(format: "%@ ~ %@",
                                            formatter.stringFromDate(work.beginDate),
                                            formatter.stringFromDate(work.endDate),
                                            work.last.formattedString )
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
            cont.workToEdit = works[id.row];
        }
        super.prepareForSegue(segue, sender: sender)
    }
    

}


extension WorkManagementVC: NewWorkVCDelegate{
    func appendNewWork(work: Part) {
        works.append(work)
        tableView.reloadData();
        println("work inserted!")
    }
    func editWork(work: Part) {
        if let id = find(works, work){
            works[id] = work;
            tableView.reloadData();
            println("work modified! \(work)");
        }else{
            assert(false, "never should come here")
        }
    }
}