//
//  NewWorkVC.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/20.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit
protocol NewWorkVCDelegate: class{
    func appendNewWork(work: Part);
    func editWork(work: Part);
}
class NewWorkVC: UITableViewController {
    //Mark: - properties
    var workToEdit: Part?
    lazy var formatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateStyle = .NoStyle
        ret.timeStyle = .ShortStyle;
        ret.timeZone = NSTimeZone(forSecondsFromGMT: 0);
        return ret;}()
    var beginDate: NSDate? {
        didSet{
            beginTimeLabel.text = formatter.stringFromDate(beginDate!);
            lastTimeLabel.text = lastTime?.formattedString;
            validateDoneButton();
        }
    }
    var endDate: NSDate? {
        didSet{
            endTimeLabel.text = formatter.stringFromDate(endDate!);
            lastTimeLabel.text = lastTime?.formattedString;
            validateDoneButton();
        }
    }
    var lastTime: NSTimeInterval? {
        get{
            if let beg = beginDate{
                if var  interval = endDate?.timeIntervalSinceDate(beg){
                    interval++;
                    if interval < 0 {
                        interval = interval + 24*3600;
                    }
                    return interval;
                }
            }
            return 0;
        }
    }
    weak var delegate: NewWorkVCDelegate?
    var timePickerIsVisible = false;
    var timePickerRow = 5;
    //Mark: - Outlets

    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    //MARK: - Actions
    @IBAction func done(sender: AnyObject) {
        if var beg = beginDate{
            if var end = endDate{
                if let work = workToEdit{
                    work.title = textField.text;
                    work.beginDate = beg;
                    work.endDate = end;
                    work.shouldRemind = shouldRemindSwitch.on;
                    delegate?.editWork(work);
                }else{
                    let work = Part(name: textField.text, beginDate: beg, endDate: end,shouldRemind: shouldRemindSwitch.on)
                    delegate?.appendNewWork(work)
                }
                println(beg);
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - Views
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder();
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if workToEdit == nil {
            beginTimeLabel.text = "0:00"
            endTimeLabel.text = "0:00"
            lastTimeLabel.text = "0:00"
        }else {
            title = "编辑班种"
            doneButton.enabled = true;
            beginDate = workToEdit!.beginDate
            endDate = workToEdit!.endDate;
            textField.text = workToEdit!.title;
            shouldRemindSwitch.on = workToEdit!.shouldRemind
        }
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && timePickerIsVisible {
            return 5
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if timePickerIsVisible && indexPath.section == 1 && indexPath.row == timePickerRow {
            
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("TimePickerCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "TimePickerCell")
                cell.selectionStyle = .None
                
                let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 216))
                datePicker.tag = 100
                cell.contentView.addSubview(datePicker)
                
                datePicker.addTarget(self, action: Selector("timeChanged:"), forControlEvents: .ValueChanged)
            }
            
            if timePickerRow == 4 {
                let picker = cell.viewWithTag(100) as! UIDatePicker; //prepare the interval picker
                picker.datePickerMode = .CountDownTimer;
                picker.minuteInterval = 5;
                picker.timeZone = NSTimeZone(forSecondsFromGMT: 0);
                if let last = lastTime{
                    picker.setDate(NSDate(timeIntervalSinceReferenceDate: last), animated: true)
                    
                }
            }else{
                let picker = cell.viewWithTag(100) as! UIDatePicker;// prepare the time time picker
                if timePickerRow == 2 {
                    if let beg = beginDate{
                        picker.setDate(beg, animated: true)
                    }
                }else if timePickerRow == 3{
                    if let end = endDate{
                        picker.setDate(end, animated: true)
                    }
                }else{
                    assert(false, "never should come here")
                }
                picker.timeZone = NSTimeZone(forSecondsFromGMT: 0);
                picker.datePickerMode = .Time;
                picker.minuteInterval = 5;
            }
            return cell
            
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textField.resignFirstResponder();
        if indexPath.section == 1 && indexPath.row != 0 && indexPath.row != timePickerRow {
            if timePickerIsVisible {
                hideTimePicker();
            }else{
                showTimePickerForRow(indexPath.row);
            }
        }
    }
    override func tableView(tableView: UITableView, var heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if timePickerIsVisible {
            if indexPath.section == 1 && indexPath.row == timePickerRow {
                return 217
            }else if indexPath.section == 1 && indexPath.row > timePickerRow{
                indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section);
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
    }
    
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if timePickerIsVisible {
            if indexPath.section == 1 && indexPath.row == timePickerRow {
                indexPath = NSIndexPath(forRow: 1, inSection: indexPath.section)
            }else if indexPath.section == 1 && indexPath.row > timePickerRow {
                indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            }
        }
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - utilities
    func validateDoneButton(){
        if(textField.text.isEmpty) || beginDate == nil || endDate == nil {
            doneButton.enabled = false;
        }else{
            doneButton.enabled = true;
        }
    }
    func showTimePickerForRow(row: Int){
        timePickerRow = row + 1;
        let insertID = NSIndexPath(forRow: row + 1, inSection: 1)
        let editingID = NSIndexPath(forRow: row, inSection: 1);
        if let cell = tableView.cellForRowAtIndexPath(editingID){
            cell.detailTextLabel!.textColor = cell.detailTextLabel!.tintColor;
        }
        timePickerIsVisible = true;
        tableView.beginUpdates();
        tableView.insertRowsAtIndexPaths([insertID], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([editingID], withRowAnimation: .None)
        tableView.endUpdates();

    }
    func hideTimePicker(){
        if !timePickerIsVisible {
            return;
        }
        let deleteID = NSIndexPath(forRow: timePickerRow, inSection: 1);
        let edittingID = NSIndexPath(forRow: timePickerRow - 1, inSection: 1)
        if let cell = tableView.cellForRowAtIndexPath(edittingID){
            cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5);
        }
        tableView.beginUpdates();
        tableView.reloadRowsAtIndexPaths([edittingID], withRowAnimation: .None);
        timePickerIsVisible = false;
        timePickerRow = 5;
        tableView.deleteRowsAtIndexPaths([deleteID], withRowAnimation: .Fade)
        tableView.endUpdates();
    }

    func timeChanged(picker: UIDatePicker){
        switch timePickerRow-1 {
        case 1:
            beginDate = picker.date;
        case 2:
            endDate = picker.date;
        case 3:
            endDate = beginDate?.dateByAddingTimeInterval(picker.countDownDuration);
        default:
            break;
        }
        assert(timePickerIsVisible, "Picker is unVisible!!")

    }
}

extension NewWorkVC: UITextFieldDelegate{
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
    func textFieldDidBeginEditing(textField: UITextField) {
        hideTimePicker();
    }
}
