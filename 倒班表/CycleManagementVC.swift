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
    var scheduleBackup: Schedule!;
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
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var riseUpView: RiseUpView!
    //@IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var riseUpTableView: UITableView!

    // MARK: - Actions

    
    @IBAction func clearAllWorks(sender: AnyObject) {
        let alert = UIAlertController(title: "清空倒班表吗？", message: "", preferredStyle: .ActionSheet) //i18n
        let action1 = UIAlertAction(title: "清空", style: .Destructive, handler: { _ in
            let days = self.scheduleToEdit.lastDays;
            self.scheduleToEdit.clearAll();
            self.tableView.deleteSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: days)), withRowAnimation: .Fade);
        })
        let action2 = UIAlertAction(title: "取消", style: .Cancel, handler: {_ in });
        alert.addAction(action1)
        alert.addAction(action2)
        presentViewController(alert, animated: true, completion: nil);
        
        

    }
    @IBAction func moveRiseUpView(sender: AnyObject){
        println("did reveived gesture");
        if let recognizer = sender as? UIGestureRecognizer{
            let position = recognizer.locationInView(view); //taping somewhere else
            println(position);
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
    func receiveDragging(rec: UIPanGestureRecognizer){
        if isRiseUp {return}
        println("panning received")
        if rec.state == .Began{
            moveRiseUpView(rec);
        }
    }
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if isRiseUp {
            riseUpView.layer.removeAllAnimations(); //set status when is up
            riseUpView.center.x = view.bounds.width / 2;
            riseUpView.center.y = view.bounds.height - (riseUpView.bounds.height / 2);
            isRiseUp = false;
            riseButton.enabled = false;
            
            // enabling the GRs;
            let arr = tableView.gestureRecognizers;
            println(arr!.count);
            let rec2 = arr!.last! as! UIPanGestureRecognizer ; // the pan GR;
            let rec = arr![arr!.count - 2] as! UITapGestureRecognizer; // the tap GR;
            rec2.enabled = true;
            rec.enabled = true;
            tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: riseUpView.frame.height, right: 0)
        }else{
            riseUpView.layer.removeAllAnimations(); // set status when is down
            riseUpView.frame.origin.x = 0;
            riseUpView.frame.origin.y = view.bounds.height - 44;
            isRiseUp = true;
            riseButton.enabled = true;
            
            //disabling the GRs
            let arr = tableView.gestureRecognizers;
            let rec2 = arr!.last! as! UIPanGestureRecognizer ; // the pan GR;
            let rec = arr![arr!.count - 2] as! UITapGestureRecognizer; // the tap GR;
            rec2.enabled = false;
            rec.enabled = false;
            tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        }
    }
    func cancel(sender: UIBarButtonItem){
        let alert = UIAlertController(title: "放弃所有更改？", message: "", preferredStyle: .ActionSheet) //i18n
        let action1 = UIAlertAction(title: "放弃", style: .Destructive, handler: { _ in
            self.scheduleToEdit = self.scheduleBackup.mutableCopy() as! Schedule;
            self.tableView.reloadData();
            self.setEditing(false, animated: true);
        })
        let action2 = UIAlertAction(title: "取消", style: .Cancel, handler: {_ in });
        alert.addAction(action1)
        alert.addAction(action2)
        presentViewController(alert, animated: true, completion: nil);
        
        
    }
    // MARK: - utilities
    private func shoudButtonBeHiddenForSeciont(section: Int) -> Bool{
        if editing {
            if let tempDay = scheduleToEdit.sectionOfTemperalDays() {
                if section == tempDay || section == tempDay + 1{
                    return true
                }
            }
            return false;
        }else{
            return true;
        }
    }
    /*
    private func updateAddDayButton(){
        if (editing){
            if let tempDays = scheduleToEdit.sectionOfTemperalDays(){
                println(scheduleToEdit.lastDays);
                for section in 0 ..< scheduleToEdit.lastDays {
                    let id = section + 429 //special tag for add Day button;
                    if let button = view.viewWithTag(id) as? UIButton{
                        println("now tempdays\(section)")
                        if section == tempDays || section == tempDays + 1{
                            button.hidden = true;
                        }else{
                            button.hidden = false;
                        }
                    }else{
                        println("find button faild in secitin:\(section)")
                    }
                }
            }
        }else{
            for section in 0 ..< scheduleToEdit.lastDays {
                let id = section + 429 //special tag for add Day button;
                if let button = view.viewWithTag(id) as? UIButton{
                    button.hidden = true;
                }
            }
        }
    }*/
    func addNewDay(sender: AnyObject ){ //inserting a new day
        assert(editing, "this method must be involked in editing mod")
        let button = sender as! UIButton;
        var id = button.tag - 429 //special tag for add Day button
        assert(id >= 0, "something wrong triggered this selector");
        if let tempDays = scheduleToEdit.sectionOfTemperalDays() {
            if(id > tempDays){--id}
            print("\(tempDays) --> \(id)\n")
            scheduleToEdit.removeEmptyDay(tempDays)
            scheduleToEdit.addEmptyDay(id);
            tableView.beginUpdates()
            tableView.deleteSections(NSIndexSet(index: tempDays), withRowAnimation: .Right);
            //self.tableView.moveSection(tempDays, toSection: id)
            self.tableView.insertSections(NSIndexSet(index: id), withRowAnimation: .Right);
            tableView.endUpdates()
            doAfterDelay(0.3){ [unowned self] in
            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location:0 , length: self.scheduleToEdit.lastDays)), withRowAnimation: .None)
            }
        }else{
            scheduleToEdit.addEmptyDay(id);
            tableView.beginUpdates();
            self.tableView.insertSections(NSIndexSet(index: id), withRowAnimation: .Right);
            tableView.endUpdates();
            doAfterDelay(0.3){
                self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location:0 , length: self.scheduleToEdit.lastDays  )), withRowAnimation: .None)
            }
        }
        
    }

    // MARK: - View;
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        var temperalDaySection = scheduleToEdit.sectionOfTemperalDays();
        tableView.setEditing(editing, animated: animated);
        trashButton.enabled = editing;
        scheduleToEdit.isInEdittingMode = editing; //data Source Chaged in Here
        if !isRiseUp {
            moveRiseUpView(self);
        }

        if editing {
            navigationItem.hidesBackButton = true; //edit button pressed
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancel:"))
            scheduleBackup = scheduleToEdit.mutableCopy() as! Schedule;
            let ids = self.scheduleToEdit.indexPathOfIntervals();
            self.tableView.deleteRowsAtIndexPaths(ids, withRowAnimation: .Top);
        }else{
            navigationItem.hidesBackButton = false; // done button pressed
            navigationItem.leftBarButtonItem = nil;
            if let idToDelete = temperalDaySection{ //如果切换回到非editing的时候，tabel中有temperal day。在这里将其删除。以下逻辑中reloadsection用了两段。将被删除的section隔开了。
                tableView.beginUpdates();
                tableView.deleteSections(NSIndexSet(index: idToDelete), withRowAnimation: .Bottom);
                tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: idToDelete)), withRowAnimation: .Bottom);
                tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: idToDelete + 1, length: scheduleToEdit.lastDays - idToDelete)), withRowAnimation: .Bottom)
                tableView.endUpdates();
            }else{
                let ids = self.scheduleToEdit.indexPathOfIntervals();
                tableView.insertRowsAtIndexPaths(ids, withRowAnimation: .Bottom)
            }

        }
        //updateAddDayButton();
        doAfterDelay(0.3, {self.tableView.reloadData()})
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
        
        //----adding the gesture recoginzers
        let rec = UITapGestureRecognizer(target: self, action: Selector("moveRiseUpView:"))
        rec.cancelsTouchesInView = false;
        rec.delaysTouchesBegan = true;
        rec.delaysTouchesEnded = true;
        rec.enabled = false;
        let rec2 = UIPanGestureRecognizer(target: self, action: Selector("receiveDragging:"))
        rec2.cancelsTouchesInView = false;
        rec2.delaysTouchesBegan = true;
        rec2.delaysTouchesEnded = true;
        rec2.enabled = false;
        tableView.addGestureRecognizer(rec);
        tableView.addGestureRecognizer(rec2);
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
        if !editing{
            return false;
        }
        if let tempDays = scheduleToEdit.sectionOfTemperalDays() {
            if indexPath.section == tempDays {
                return false
            }
        }
        return true
    }
    // Override to support conditional rearranging of the table view.
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let tempDays = scheduleToEdit.sectionOfTemperalDays() {
            if indexPath.section == tempDays {
                return false
            }
        }
        return true
    }
}
extension CycleManagementVC :UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("asking the number of work in day\(section): \(scheduleToEdit.numberOfWorksInDay(section))");
        return scheduleToEdit.numberOfWorksInDay(section);
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return scheduleToEdit.lastDays;
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lebelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 17, width: tableView.bounds.width / 2, height: 17);
        let label = UILabel(frame: lebelRect);
        label.font = UIFont.systemFontOfSize(14);
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section);
        label.textColor = UIColor.blackColor()  // color of header titel font
        label.backgroundColor = UIColor.clearColor()
        
        let seperatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 1, width: tableView.bounds.size.width - 15, height: 1)
        let separator = UIView(frame: seperatorRect)
        separator.backgroundColor = tableView.tintColor; // color of separator
        
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 1, alpha: 0.85); // color of background
        view.addSubview(label)
        view.addSubview(separator)

        let buttonWidth: CGFloat = 40;
        let buttonRect = CGRect(x: tableView.bounds.width - buttonWidth - 15, y: tableView.sectionHeaderHeight - 17,
                                width: buttonWidth, height: 17)
        let button = UIButton(frame: buttonRect);
        button.setTitle("新增", forState: .Normal) //i18n
        button.setTitleColor(button.tintColor, forState: .Normal);
        button.setTitleColor(UIColor(white: 0, alpha: 0.15), forState: .Highlighted);
        button.showsTouchWhenHighlighted = true;
        button.titleLabel?.font = UIFont.systemFontOfSize(14);
        button.addTarget(self, action: Selector("addNewDay:"), forControlEvents: .TouchUpInside);
        button.hidden = shoudButtonBeHiddenForSeciont(section);
        button.tag = 429 + section;
        view.addSubview(button)
        
        return view
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("asking for indexPath\(indexPath.section),\(indexPath.row)");
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
        }else if work is TemperalPart {
            cell.textLabel?.text = "(temperal cell)"
            cell.detailTextLabel?.text = ""
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
        if sourceIndexPath == proposedDestinationIndexPath {return sourceIndexPath }
        let workToReorder = scheduleToEdit.workForIndexPath(sourceIndexPath);
        if let destination = scheduleToEdit.positionForWork(workToReorder, forIndex: proposedDestinationIndexPath) {
            println("should redestinated to \(destination.section),\(destination.row)")
            return destination;
        }else{
            println("should not move");
            //canntFindProperPlaceForIndexPath(proposedDestinationIndexPath);
            //let ret = NSIndexPath(forRow: 0, inSection: proposedDestinationIndexPath.section)
            return sourceIndexPath;
        }
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if fromIndexPath == toIndexPath {return}
        let workToReorder = scheduleToEdit.workForIndexPath(fromIndexPath);
        if scheduleToEdit.removeWork(fromIndexPath) { // the retrun value of this method indicate if it needs to remove the whole damn section
            var newToIndex: NSIndexPath!;
            if(toIndexPath.section > fromIndexPath.section){  // if the move is from up to down , the destination section should decrease;
                newToIndex = NSIndexPath(forRow: toIndexPath.row, inSection: toIndexPath.section - 1);
            }else{
                newToIndex = toIndexPath;
            }
            println("moving cell \(fromIndexPath.section),\(fromIndexPath.row) -> \(newToIndex.section),\(newToIndex.row)")

            scheduleToEdit.addWork(workToReorder, inIndex: newToIndex); //newToIndex 是delete操作后应该insert的位置。toIndexPath是delete前应该insert的位置。
            
            let set = NSIndexSet(index: fromIndexPath.section)
            doAfterDelay(0.3){ //delay to avoid disturbing the cell move animation!
                tableView.beginUpdates()
                tableView.deleteSections(set, withRowAnimation: .Fade)
                self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: toIndexPath.section, length: 1)), withRowAnimation: .None) //此处应该用delete前的位置toIndexPath来更新section。因为在update块中的reload的index都应该是delete前的位置。
                println("*******relaoded range: \(newToIndex.section):\(1)****deleteSection:\(set.firstIndex)")
                tableView.endUpdates();
            }
            
            doAfterDelay(0.6){ //为了省事每次移动cell之后都会刷新所有section。这样做可能不是最好的办法。特别是从从上面删除section 插入到下面的tempdays中时的动画不是很好看。
                self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: self.scheduleToEdit.lastDays)), withRowAnimation: .None)
            }
        }else{

            scheduleToEdit.addWork(workToReorder, inIndex: toIndexPath);
            doAfterDelay(0.3){
                tableView.reloadSections(NSIndexSet(index: toIndexPath.section), withRowAnimation: .Fade);
            }
            doAfterDelay(0.6){ //为了及时更新各个section 的header。不断地reload。这样做应该不是最好的办法
                self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: self.scheduleToEdit.lastDays)), withRowAnimation: .None)
            }        }

    }
    
}

extension CycleManagementVC: UINavigationBarDelegate{ //deal with the status bar
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
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