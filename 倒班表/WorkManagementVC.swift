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
    weak var dataLib: DataLib!
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
    required init? (coder aDecoder: NSCoder){
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
        return dataLib.worksLib.count;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowEditWork", sender: indexPath)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkCell", forIndexPath: indexPath) 
        cell.textLabel!.text = dataLib.worksLib[indexPath.row].title;
        let work = dataLib.worksLib[indexPath.row];
        cell.detailTextLabel!.text = String(format: "%@ ~ %@",
                                            work.begin.formattedString,work.end.formattedString )
        return cell
    }
    


    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dataLib.worksLib.removeAtIndex(indexPath.row);
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
            cont.workToEdit = dataLib.worksLib[id.row];
        }
        super.prepareForSegue(segue, sender: sender)
    }
    

}


extension WorkManagementVC: NewWorkVCDelegate{
    func appendNewWork(work: Part) {
        dataLib.worksLib.append(work)
        tableView.reloadData();
        print("work inserted!")
    }
    func editWork(work: Part) {
        if let id = dataLib.worksLib.indexOf(work){
            dataLib.worksLib[id] = work;
            tableView.reloadData();
            print("work modified! \(work): now color is \(work.color)");
        }else{
            assert(false, "never should come here")
        }
    }
}