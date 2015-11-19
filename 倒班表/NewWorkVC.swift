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
    var partColor: UIColor?
    weak var delegate: NewWorkVCDelegate?
    var timePickerIsVisible = false;
    var timePickerRow = 5;
    var colorScroller: ColorScrollerView!
    //Mark: - Outlets

    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    //MARK: - Actions
    @IBAction func done(sender: AnyObject) {
        if let beg = beginDate{
            if let end = endDate{
                if let work = workToEdit{
                    work.title = textField.text!;
                    work.beginDate = beg;
                    work.endDate = end;
                    work.shouldRemind = shouldRemindSwitch.on;
                    delegate?.editWork(work);
                }else{
                    let work = Part(name: textField.text!, beginDate: beg, endDate: end,shouldRemind: shouldRemindSwitch.on)
                    delegate?.appendNewWork(work)
                }
                print(beg);
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
        tableView.reloadData()
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))!
        colorScroller = ColorScrollerView(frame: cell.contentView.bounds)
        colorScroller.target = self
        cell.contentView.addSubview(colorScroller)
        if workToEdit == nil {
            beginTimeLabel.text = "0:00"
            endTimeLabel.text = "0:00"
            lastTimeLabel.text = "0:00"
            partColor = generateRandomColor();
        }else {
            title = "编辑班种"
            doneButton.enabled = true;
            beginDate = workToEdit!.beginDate
            endDate = workToEdit!.endDate;
            textField.text = workToEdit!.title;
            shouldRemindSwitch.on = workToEdit!.shouldRemind
            partColor = workToEdit!.color
        }
        doAfterDelay(2.5, closure: {
            self.colorScroller.scrollTo(self.partColor!)
        })

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
            
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("TimePickerCell")
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
        }else{
            if timePickerIsVisible {
                hideTimePicker()
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
    // MARK: - utilities
    func validateDoneButton(){
        if(textField.text!.isEmpty) || beginDate == nil || endDate == nil {
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
    private func generateRandomColor()->UIColor{
        let id = random() % colorScroller.colorVector.count
        return colorScroller.colorVector[id]
    }
    //MARK: - Selectors!
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
    func colorPicked(button: UIButton){
        print("colorPicked")
    }
}

extension NewWorkVC: UITextFieldDelegate{
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
    func textFieldDidBeginEditing(textField: UITextField) {
        hideTimePicker();
    }
}



class ColorScrollerView: UIScrollView{
    let SPACE: CGFloat = 100;
    let BUTTON_WIDTH: CGFloat = 22;
    var target: AnyObject!
    var colorVector:[UIColor] = [
        UIColor.blueColor(),
        UIColor.greenColor(),
        UIColor.yellowColor(),
        UIColor.orangeColor(),
        UIColor.purpleColor()
    ]
    func scrollTo(color: UIColor){
        if let id = colorVector.indexOf(color){
            let x = SPACE * CGFloat(id) + SPACE / 2
            self.contentOffset = CGPoint(x: x, y: 0);
        }else{
            assert(false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentSize = CGSize(width: SPACE * CGFloat(colorVector.count), height: self.bounds.height)
        var posiInX = SPACE / 2
        for (var i = 0; i != colorVector.count; ++i){
            let color = colorVector[i]
            posiInX += SPACE;
            let but = getButtonInColor(color, posi: posiInX)
            but.tag = i;
            self.addSubview(but)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        assert(false)
        super.init(coder: aDecoder)
    }
    private func getButtonInColor(color: UIColor,posi: CGFloat) -> UIButton{
        let but = UIButton(type: .System)
        but.frame = CGRect(x: posi - BUTTON_WIDTH / 2,
            y: self.bounds.height / 2 - BUTTON_WIDTH / 2,
            width: BUTTON_WIDTH,
            height: BUTTON_WIDTH)
        but.addTarget(target, action: Selector("colorPicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        but.backgroundColor = color;
        but.layer.cornerRadius = BUTTON_WIDTH / 2;
        return but;
    }
}