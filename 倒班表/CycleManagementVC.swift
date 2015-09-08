//
//  NewScheduleVCViewController.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/25.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit
import QuartzCore

class CycleManagementVC: UIViewController {

    
    // MARK: - Properties
    var scheduleToEdit :Schedule!;
    var worksLib: WorksLib!;
    var isRiseUp = true;
    lazy var formatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateStyle = .NoStyle
        ret.timeStyle = .ShortStyle;
        ret.timeZone = NSTimeZone(forSecondsFromGMT: 0);
        return ret;}()
    // MARK: - Outlets
    @IBOutlet weak var riseButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var riseUpView: RiseUpView!
    //@IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var riseUpTableView: UITableView!

    // MARK: - Actions
    /*
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }*/

    @IBAction func moveRiseUpView(sender: AnyObject){
        if let recognizer = sender as? UIGestureRecognizer{
            let position = recognizer.locationInView(riseUpTableView); //taping somewhere else
            let indexPath = riseUpTableView.indexPathForRowAtPoint(position);
            if indexPath != nil {
                return; // cancel move if toucing the riseup cell
            }
        }else{ // tapping the add button
            
        }

        let riser = CABasicAnimation(keyPath: "position")
        riser.removedOnCompletion = false;
        riser.fillMode = kCAFillModeForwards;
        riser.duration = 0.3;
        riser.fromValue = NSValue(CGPoint: riseUpView.center)
        if isRiseUp {
            riser.toValue = NSValue(CGPoint: CGPoint(x: riseUpView.center.x, y: riseUpView.center.y - 176));
            riser.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        }else{
            riser.toValue = NSValue(CGPoint: CGPoint(x: riseUpView.center.x, y: riseUpView.center.y + 176));
            riser.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        }
        riser.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        riser.delegate = self;
        riseUpView.layer.addAnimation(riser, forKey: "riseUpViewMove");
    }

    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if isRiseUp {
            riseUpView.layer.removeAllAnimations(); //set status when is up
            riseUpView.center.x = view.bounds.width / 2;
            riseUpView.center.y = view.bounds.height - (riseUpView.bounds.height / 2);
            isRiseUp = false;
            riseButton.enabled = false;
            let rec = UITapGestureRecognizer(target: self, action: Selector("moveRiseUpView:"))
            rec.cancelsTouchesInView = false;
            rec.delegate = self
            view.addGestureRecognizer(rec);
            tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: riseUpView.frame.height, right: 0)
        }else{
            riseUpView.layer.removeAllAnimations(); // set status when is down
            riseUpView.frame.origin.x = 0;
            riseUpView.frame.origin.y = view.bounds.height - 44;
            isRiseUp = true;
            riseButton.enabled = true;
            let rec = view.gestureRecognizers?[0] as! UITapGestureRecognizer;
            view.removeGestureRecognizer(rec);
            tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        }
    }
    // MARK: - View;
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated);
        scheduleToEdit.isInEdittingMode = editing;
        if !isRiseUp {
            moveRiseUpView(self);
        }

        if editing {
            let ids = self.scheduleToEdit.indexPathOfIntervals();
            self.tableView.deleteRowsAtIndexPaths(ids, withRowAnimation: .Top);
        }else{
            let ids = self.scheduleToEdit.indexPathOfIntervals();
            self.tableView.insertRowsAtIndexPaths(ids, withRowAnimation: .Bottom);
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        let button2 = toolBar.items?[1] as! UIBarButtonItem;
        button2.width = (view.bounds.width - 88) //the width of the trash item is 44!
        riseUpView.worksLib = worksLib;
        riseUpView.delegate = self;
        scheduleToEdit.isInEdittingMode = false
        navigationItem.rightBarButtonItem = editButtonItem();
        //tableView.setEditing(true, animated: true);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CycleManagementVC :UITableViewDelegate{
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    // Override to support conditional rearranging of the table view.
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
}
extension CycleManagementVC :UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleToEdit.numberOfWorksInDay(section);
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return scheduleToEdit.lastDays;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let cell2 = tableView.dequeueReusableCellWithIdentifier("worksArrangementCell") as? UITableViewCell {
            cell = cell2;
        }else {
            cell =  UITableViewCell(style: .Value1, reuseIdentifier: "worksArrangementCell");
        }
        let work = scheduleToEdit.workForIndexPath(indexPath);
        if work is BreakPart {
            cell.textLabel?.text = "休息时间"
            cell.detailTextLabel?.text = "时长：\(work.last.formattedString)";
        }else{
            cell.textLabel?.text = work.title;
            cell.detailTextLabel?.text = work.descriptionIn24h;
        }

        
        return cell;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(format:"第%d天",section+1);
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if scheduleToEdit.removeWork(indexPath) {
                let set = NSIndexSet(index: indexPath.section)
                tableView.deleteSections(set, withRowAnimation: .Fade) // delete the whole damn section
                doAfterDelay(0.3, {tableView.reloadData()}) // using this asynchronous method could be a little dangerous
                
            }else{
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade); //just delet the row
            }
        }
    }
    
    // Override to support rearranging the table view.
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        let workToReorder = scheduleToEdit.workForIndexPath(sourceIndexPath);
        if let destination = scheduleToEdit.positionForWork(workToReorder, forIndex: proposedDestinationIndexPath) {
            println("should redestinated to \(destination.section),\(destination.row)")
            return destination;
        }else{
            println("should not move")
            return sourceIndexPath;
        }
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if fromIndexPath == toIndexPath {return}
        let workToReorder = scheduleToEdit.workForIndexPath(fromIndexPath);
        scheduleToEdit.removeWork(fromIndexPath);
        scheduleToEdit.addWork(workToReorder, inIndex: toIndexPath);

    }
    
}

extension CycleManagementVC: UINavigationBarDelegate{ //deal with the status bar
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension CycleManagementVC: UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let views = riseUpView.subviews as! [UIView];
        if let ok = find(views, touch.view) {
            return false
        }else{
            return true;
        }
        
    }
    


}

extension CycleManagementVC: RiseUpViewDelegate {
    func riseUpViewDidSelectId(indexPath: NSIndexPath) {
        let id = indexPath.row;
        let workToAppend = worksLib.lib[id];
        if let idToInsert = scheduleToEdit.appendWork(workToAppend){
            //if idToInsert.row == -1 {
           //     let id = NSIndexPath(forRow: 0, inSection: idToInsert.section);
             //   tableView.insertRowsAtIndexPaths([id], withRowAnimation: .Fade)
           // }else{
                tableView.insertRowsAtIndexPaths([idToInsert], withRowAnimation: .Fade);
           // }
        }else{
            let set = NSIndexSet(index: scheduleToEdit.lastDays - 1)
            println("will insert sections at \(scheduleToEdit.lastDays)");
            tableView.insertSections(set, withRowAnimation: .Fade)
        }
        println("did insert schedule at last")
    }

    
}