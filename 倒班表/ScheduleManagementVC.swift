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
    func scheduleManagementVC(scheduleApplied schedule: Schedule);
    func scheduleManagementVC(cancelSchedule schedule: Schedule, retreatToSchedule ori: Schedule);
}
class ScheduleManagementVC: UITableViewController {
    // MARK: - properties
    var scheduleBackUp: Schedule!
    var scheduleToEdit: Schedule!;
    weak var dataLib: DataLib!;
    var delegate: ScheduleManagemenVCDelegate?
    // MARK: - Outlets
    @IBOutlet weak var applyButton: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    //MARK: - Action
    @IBAction func done(sender: AnyObject) {
        scheduleToEdit.title = textField.text;
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
    //MARK: - Views;
    override func viewWillAppear(animated: Bool) {
        validateDoneButton();
        println("view will apear");
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        println("view did load")
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        let sec = indexPath.section
        let row = indexPath.row
        switch(sec,row){
        case(3,0):
            break;
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
        default:
            break;
        }
        if(sec != 0 ){
            textField.resignFirstResponder();
        }
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
        let oldText: NSString = textField.text
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        if newText.length > 0 {
            validateDoneButton();
        }else{
            doneButton.enabled = false;
        }
        return true;
    }
}
