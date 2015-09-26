//
//  NowVC.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

class NowVC: UIViewController {
    //MARK: - properties
    weak var dataLib: DataLib!
    weak var scheduleParsor: ScheduleParsor!;
    lazy var dateFormatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateStyle = .ShortStyle
        ret.timeStyle = .MediumStyle;
        return ret;}()
    lazy var timeFormatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateFormat = "HH:mm"
        return ret;}()
    //MAKR: - Outlets
    @IBOutlet weak var cycleViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cycleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nowDateLabel: UILabel!
    @IBOutlet weak var scheduleNameLabel: UILabel!
    
    @IBOutlet weak var dayNoLabel: UILabel!
    @IBOutlet weak var timeRemain2Label: UILabel!
    @IBOutlet weak var nowWorkNameLabel: UILabel!
    @IBOutlet weak var timeRemainLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var worksNoLabel: UILabel!
    @IBOutlet weak var worksListLabel: UILabel!
    //MARK: - Actions
    func timerFired(timer: NSTimer){ //a run loop updating the UI
        nowDateLabel.text = dateFormatter.stringFromDate(NSDate());
        updateLabel();
    }
    //MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cycleWidth = view.bounds.size.width * 0.8
        cycleViewWidthConstraint.constant = cycleWidth
        cycleViewHeightConstraint.constant = cycleWidth
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
        scheduleParsor = dataLib.scheduleParsor;
        updateLabel();
        print("timeer scheduled");
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - utilities
    private func updateLabel(){
        scheduleNameLabel.text = scheduleParsor.schedule?.title
        if scheduleParsor.isApplying {
            let now = NSDate();
            let work = scheduleParsor.workForDate(now);
            if work is BreakPart {
                nowWorkNameLabel.text = "Break"
                timeRemainLabel.text = "\(scheduleParsor.nextWorkForDate(now)!.title): " + timeFormatter.stringFromDate(scheduleParsor.nextKeyTime!)
            }else{
                
                timeRemainLabel.text = timeFormatter.stringFromDate(scheduleParsor.nextKeyTime!)
                nowWorkNameLabel.text = "\(work!.title)"
            }
            timeRemain2Label.text = timeFormatter.stringFromDate(scheduleParsor.timeToNextKeyTime!)
            worksNoLabel.text = " \(scheduleParsor.partNoForDate(now)!) of \(scheduleParsor.schedule!.numberOfWorksInDay(scheduleParsor.dayNoForDate(now)!)) "
            dayNoLabel.text = String(format: "%d of %d", scheduleParsor.dayNoForDate(now)!,scheduleParsor.schedule!.lastDays);
        }else{
            timeRemainLabel.text = "No Schedule is Applying"
            percentageLabel.text = "N/A"
            worksNoLabel.text = "0 of 0"
            worksListLabel.text = "(no list)"
            dayNoLabel.text = "N/A"
        }
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
