//
//  ScheduleManagementVCTableViewController.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/5.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

class ScheduleManagementVC: UITableViewController {
    // MARK: - properties
    var scheduleToEdit: Schedule!;
    var worksLib: WorksLib!;
    // MARK: - Outlets
    @IBOutlet weak var applyButton: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    //MARK: - Action
    @IBAction func done(sender: AnyObject) {
        
    }
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    //MARK: - Views;
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton.textColor = applyButton.tintColor;
        textField.becomeFirstResponder();
        if scheduleToEdit.title == "" {
            navigationItem.title = "新建倒班周期"
        }else{
            navigationItem.title = scheduleToEdit.title;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if(indexPath.section != 0 ){
            textField.resignFirstResponder();
        }
    }    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditCycle" {
            let controller = segue.destinationViewController as! CycleManagementVC;
            controller.worksLib = self.worksLib
            controller.scheduleToEdit = self.scheduleToEdit;
        }
    }
    //MARK: - Utilities
    private func validateDoneButton(){
        if(true){
            doneButton.enabled = true;
        }else{
            //doneButton.enabled = false;
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
