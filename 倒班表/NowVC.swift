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
    var tiCache: [NSTimeInterval]!
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
        let now  = NSDate()
        headerView.spinnerView.move(now.timeIntervalSinceDate(updateTime), speed:0.5);
        updateTime = now;
        updateLabel();

    }
    //MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CycleSpinnerViewXib", bundle: nil)
        let viewsInNib = nib.instantiateWithOwner(nil,options: nil) as! [NowHeaderView]
        headerView = viewsInNib[0]
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 400)
        headerView.spinnerView.delegate = self
        tableView.tableHeaderView = headerView
        let timer = NSTimer(timeInterval: 60*5, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
        timer.tolerance = 60;
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        scheduleParsor = dataLib.scheduleParsor;
        tiCache = scheduleParsor.intervalsWithin25HFrom(NSDate());
        print(tiCache)
        print("timeer scheduled");
        doAfterDelay(0.5, closure: {
            self.headerView.spinnerView.start();
            self.updateTime = NSDate()
            self.updateLabel()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - utilities
    private func updateLabel(){
        headerView.scheduleLabel.text = scheduleParsor.schedule?.title
        headerView.todayLabel.text = dateFormatter.stringFromDate(updateTime)
        
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

extension NowVC: CycleSpinnerViewDelegate{
    func propertyOfNewPartInCycleSpinnerView(cycleSpinnerView: CycleSpinnerView) -> (NSTimeInterval, UIColor) {
        var color: UIColor!
        switch(random() % 3){
        case 0:
            color = UIColor.blueColor();
        case 1:
            color = UIColor.redColor();
        case 2:
            color = UIColor.greenColor();
        default:
            assert(false)
        }
        var len: NSTimeInterval!
        if tiCache.isEmpty{
            let date = scheduleParsor.date(NSDate(),afterdays:1);
            len = scheduleParsor.workForDate(date)?.last
        }else{
            len = tiCache[0];
            tiCache.removeAtIndex(0)
        }
        return (len,color)
    }
    
}

class NowHeaderView: UIView{
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var spinnerView: CycleSpinnerView!
    @IBOutlet weak var scheduleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        print(spinnerView.frame)
    }
}

