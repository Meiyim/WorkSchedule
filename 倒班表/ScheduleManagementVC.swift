//
//  ScheduleManagementVCTableViewController.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/5.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit
protocol ScheduleManagemenVCDelegate: class {
    func scheduleManagementVC(commitChange schedule: Schedule,completion closure: (()->())?) ;
    func scheduleManagementVC(deleteSchedule schedule: Schedule);
    func scheduleManagementVC(scheduleApplied schedule: Schedule, toDate: NSDate);
    func scheduleManagementVC(cancelSchedule schedule: Schedule, retreatToSchedule ori: Schedule);
}
class ScheduleManagementVC: UITableViewController {
    // MARK: - properties
    var scheduleBackUp: Schedule!
    var scheduleToEdit: Schedule!;
    weak var dataLib: DataLib!;
    var delegate: ScheduleManagemenVCDelegate?
    // MARK: - constant
    var rowNumberOfPickerCell = 1;
    var sectionNumberOfPickerCell = 3;
    var timePickerIsVisible = false
    // MARK: - Outlets
    @IBOutlet weak var applyButton: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var applyCell: UITableViewCell!
    @IBOutlet weak var confirmCancelCell: UITableViewCell!
    //MARK: - Action
    @IBAction func done(sender: AnyObject) {
        scheduleToEdit.title = textField.text!;
        delegate?.scheduleManagementVC(commitChange: scheduleToEdit, completion: nil);
        dismissViewControllerAnimated(true, completion: nil);
    }
    @IBAction func cancel(sender: AnyObject){
        let alert = UIAlertController(title: "放弃所有更改？", message: "", preferredStyle: .ActionSheet) //i18n
        let action1 = UIAlertAction(title: "放弃", style: .Destructive, handler: { _ in
            // read back up
            self.delegate?.scheduleManagementVC(cancelSchedule: self.scheduleToEdit, retreatToSchedule: self.scheduleBackUp)
            self.dismissViewControllerAnimated(true, completion: nil);
        })
        let action2 = UIAlertAction(title: "取消", style: .Cancel, handler: {_ in });
        alert.addAction(action1)
        alert.addAction(action2)
        presentViewController(alert, animated: true, completion: nil);
    }
    @IBAction func textFieldEndTyping(sender: AnyObject) {
        textField.resignFirstResponder();
    }
    func timeChanged(sender: UIDatePicker){
        print(sender.date)
    }
    func didTouched(sender: UITapGestureRecognizer){
        let posi = sender.locationInView(tableView)
        let id = tableView.indexPathForRowAtPoint(posi)
        if id?.section != sectionNumberOfPickerCell && id?.section != 0 {
            textField.resignFirstResponder();
            hideApplyConfirm()
        }
    }
    //MARK: - Views;
    override func viewWillAppear(animated: Bool) {
        validateDoneButton();
        print("view will apear");
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        doneButton.enabled = false;
        textField.text = scheduleToEdit.title;
        applyButton.textColor = applyButton.tintColor;
        textField.becomeFirstResponder();
        if scheduleToEdit.title == "" {
            navigationItem.title = "新建倒班周期"
        }else{
            navigationItem.title = scheduleToEdit.title;
        }
        scheduleBackUp = scheduleToEdit.mutableCopy() as! Schedule;
        let gest = UITapGestureRecognizer();
        gest.cancelsTouchesInView = false;
        gest.addTarget(self, action: "didTouched:")
        view.addGestureRecognizer(gest);
        print("*** is now applying: \(dataLib.scheduleParsor.isApplying)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - TableView delegate
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if timePickerIsVisible && indexPath.section == sectionNumberOfPickerCell{
            if indexPath.row != rowNumberOfPickerCell + 1{
                return nil
            }else{
                return indexPath;
            }
        }else{
            return indexPath
        }
    }
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if timePickerIsVisible {
            if indexPath.section == sectionNumberOfPickerCell && indexPath.row == rowNumberOfPickerCell {
                indexPath = NSIndexPath(forRow: 0, inSection: sectionNumberOfPickerCell);
            }else if indexPath.section == sectionNumberOfPickerCell && indexPath.row > rowNumberOfPickerCell{
                indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
            }
        }
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }
    override func tableView(tableView: UITableView, var heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if timePickerIsVisible {
            if indexPath.section == sectionNumberOfPickerCell && indexPath.row == rowNumberOfPickerCell{
                return 217
            }else if indexPath.section == sectionNumberOfPickerCell && indexPath.row > rowNumberOfPickerCell{
                indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section);
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        let sec = indexPath.section
        let row = indexPath.row
        switch(sec,row){
        case(3,0):
            showApplyConfirm();
        case(3,1):
            let alert = UIAlertController(title: "删除此倒班表？？", message: "", preferredStyle: .ActionSheet) //i18n
            let action1 = UIAlertAction(title: "删除", style: .Destructive, handler: { _ in
                self.delegate?.scheduleManagementVC(deleteSchedule: self.scheduleToEdit);
                self.dismissViewControllerAnimated(true, completion: nil);
            })
            let action2 = UIAlertAction(title: "取消", style: .Cancel, handler: {_ in });
            alert.addAction(action1)
            alert.addAction(action2)
            presentViewController(alert, animated: true, completion: nil);
        case(3,2): //hitting the confirm button
            confirmApplication()
        default:
            hideApplyConfirm();
        }
        if(sec != 0 ){
            textField.resignFirstResponder();
        }
    }
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionNumberOfPickerCell && timePickerIsVisible {
            return 3
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    override func tableView(tableView: UITableView, var cellForRowAtIndexPath  indexPath: NSIndexPath) -> UITableViewCell {
        if timePickerIsVisible {
            if indexPath.section == sectionNumberOfPickerCell && indexPath.row == rowNumberOfPickerCell{
                var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("TimePickerCell")
                if cell == nil{
                    cell = UITableViewCell(style: .Default, reuseIdentifier: "TimePickerCell")
                    cell.selectionStyle = .None;
                    let picker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 216))
                    picker.tag = 100;
                    picker.addTarget(self, action: Selector("timeChanged:"), forControlEvents: .ValueChanged)
                    picker.datePickerMode = .Date;
                    picker.maximumDate = NSDate();
                    picker.minimumDate = dataLib.scheduleParsor.aYearAgoOf(NSDate());
                    cell.contentView.addSubview(picker);
                    
                }
                return cell;
            }else if indexPath.section == sectionNumberOfPickerCell && indexPath.row > rowNumberOfPickerCell {
                indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            }
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditCycle" {
            let controller = segue.destinationViewController as! CycleManagementVC;
            controller.dataLib = self.dataLib;
            controller.scheduleToEdit = self.scheduleToEdit;
        }
    }
    //MARK: - Utilities
    private func confirmApplication(){
        let picker = tableView.viewWithTag(100) as! UIDatePicker
        delegate?.scheduleManagementVC(scheduleApplied: scheduleToEdit, toDate: picker.date);
        //此处可以有动画
        dismissViewControllerAnimated(true, completion: nil)
    }
    private func showApplyConfirm(){
        if timePickerIsVisible {return}
        let insertID = NSIndexPath(forRow: rowNumberOfPickerCell, inSection: sectionNumberOfPickerCell)
        
        timePickerIsVisible = true;
        tableView.insertRowsAtIndexPaths([insertID], withRowAnimation: .Fade)
        let label = applyCell.viewWithTag(101) as! UILabel
        label.text = "新周期将起始于..." //i18n
        
        let label2 = confirmCancelCell.viewWithTag(102) as! UILabel
        label2.text = "确认" // i18n
        label2.textColor = label2.tintColor
        
    }
    private func hideApplyConfirm(){
        if !timePickerIsVisible {return}
        timePickerIsVisible = false;
        let deleteID = NSIndexPath(forRow: rowNumberOfPickerCell, inSection: sectionNumberOfPickerCell)
        tableView.deleteRowsAtIndexPaths([deleteID], withRowAnimation: .Fade)
        let label = applyCell.viewWithTag(101) as! UILabel
        label.text = "应用倒班周期" //i18n
        
        let label2 = confirmCancelCell.viewWithTag(102) as! UILabel
        label2.text = "删除" // i18n
        label2.textColor = UIColor.redColor();
    }
    private func validateDoneButton(){
        if(scheduleToEdit.okToUse){
            doneButton.enabled = true;
        }else{
            doneButton.enabled = false;
        }
    }

}

extension ScheduleManagementVC: UITextFieldDelegate{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        if newText.length > 0 {
            validateDoneButton();
        }else{
            doneButton.enabled = false;
        }
        return true;
    }
}
