//
//  NowVC.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/19.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

class NowVC: UITableViewController {
    //MARK: - properties
    weak var dataLib: DataLib!
    weak var scheduleParsor: ScheduleParsor!;
    var headerView: NowHeaderView!
    var updateTime: NSDate!
    lazy var dateFormatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateStyle = .ShortStyle
        ret.timeStyle = .MediumStyle;
        return ret;}()
    lazy var timeFormatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateFormat = "HH:mm"
        return ret;}()
    //MAKR: - Outlets
    //MARK: - Actions
    func timerFired(timer: NSTimer){ //a run loop updating the UI
        print("fired")
        updateLabel();
        let now  = NSDate()
        headerView.spinnerView.move(now.timeIntervalSinceDate(updateTime), speed:0.5);
        updateTime = now;
    }
    //MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CycleSpinnerViewXib", bundle: nil)
        let viewsInNib = nib.instantiateWithOwner(nil,options: nil) as! [NowHeaderView]
        headerView = viewsInNib[0]
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 400)
        tableView.tableHeaderView = headerView
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
        scheduleParsor = dataLib.scheduleParsor;
        updateLabel();
        print("timeer scheduled");
        print(self.tableView.frame)
        print(self.view.bounds)
        doAfterDelay(0.5, closure: {
            self.headerView.spinnerView.start();
            self.updateTime = NSDate()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - utilities
    private func updateLabel(){
        headerView.scheduleLabel.text = scheduleParsor.schedule?.title
        headerView.todayLabel.text = dateFormatter.stringFromDate(NSDate())
        
    }
    //MARK: - tableView delegate/ dataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NowVCCell", forIndexPath: indexPath)
        cell.textLabel?.text = "good"
        cell.detailTextLabel?.text = "great"
        
        return cell
    }
}



class NowHeaderView: UIView{
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var spinnerView: CycleSpinnerView!
    @IBOutlet weak var scheduleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        spinnerView.delegate = self
        print(spinnerView.frame)
    }
}
extension NowHeaderView: CycleSpinnerViewDelegate{
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
