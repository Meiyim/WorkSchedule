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
    weak var spinnerView: CycleSpinnerView!;
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
        spinnerView.move(3600, speed:1);
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
        let rect = CGRect(x: (view.bounds.width - cycleWidth) / 2, y: (view.bounds.height - cycleWidth) / 2,
            width: cycleWidth, height: cycleWidth)
        let vi = CycleSpinnerView(frame: rect)
        vi.delegate = self;
        vi.opaque = false;
        spinnerView = vi;
        view.addSubview(vi);
        //vi.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5);
        print("timeer scheduled");
        //doAfterDelay(1.0, closure: {  self.spinnerView.move(15 * 60, speed: 1) }  )
        doAfterDelay(1.0, closure: { self.spinnerView.start() })
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
            worksNoLabel.text = String(scheduleParsor.partNoForDate(now)!)
            dayNoLabel.text = String(format: "%d", scheduleParsor.dayNoForDate(now)!);
            var str = ""
            for interval in scheduleParsor.intervalsWithin25HFrom(now)! {
                str += "\(interval.formattedString),\n";
            }
            worksListLabel.text = str;
            percentageLabel.text = String(format:"%4.1f%@" ,"%",scheduleParsor.progressInCycle * 100 );
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

extension NowVC: CycleSpinnerViewDelegate{
    func propertyOfNewPartInCycleSpinnerView(cycleSpinnerView: CycleSpinnerView) -> (NSTimeInterval, UIColor) {
        var color: UIColor!
        switch(random() % 3){
        case 0:
            color = UIColor.yellowColor();
        case 1:
            color = UIColor.redColor();
        case 2:
            color = UIColor.greenColor();
        default:
            assert(false)
        }
        return (3600*2,color)
    }

}
