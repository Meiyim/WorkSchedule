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
    weak var scheduleParsor: ScheduleParsor!
    var headerView: NowHeaderView!
    var tiCache: [NSTimeInterval]!
    var updateTime: NSDate!
    lazy var dateFormatter: NSDateFormatter = { let ret = NSDateFormatter();
        ret.dateFormat = "MM/dd"
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
    override func viewDidLoad() {   // involk when first lauch app!!!!!
        scheduleParsor = dataLib.scheduleParsor;
        super.viewDidLoad()
        
        //config headerView
        let nib = UINib(nibName: "CycleSpinnerViewXib", bundle: nil)
        let viewsInNib = nib.instantiateWithOwner(nil,options: nil) as! [NowHeaderView]
        headerView = viewsInNib[0]
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 400)
        headerView.spinnerView.delegate = self
        tableView.tableHeaderView = headerView
        navigationItem.title = "Now"
        scheduleParsor.spinnerView = self.headerView.spinnerView

        let nib2 = UINib(nibName: "NowTableViewCell", bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: "NowTableCell")
        
        let timer = NSTimer(timeInterval: 60*5, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
        timer.tolerance = 60;
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)


        print("timeer scheduled");

    }
    override func viewWillAppear(animated: Bool) {  // involked every time when now vc is shown
        super.viewWillAppear(animated)
        tiCache = scheduleParsor.intervalsWithin25HFrom(NSDate());
        print("time interval cache activated!: \n \(tiCache)")
        self.updateTime = NSDate()
        self.updateLabel()
        doAfterDelay(0.5, closure: {
            if(self.scheduleParsor.isApplying){
                self.headerView.spinnerView.start();
                
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - utilities
    private func sectionForScheduleParsor(nowSec: Int) -> Int { // from the section used in nowvc to section used in SP
        return nowSec + scheduleParsor.dayNoForDate(NSDate())!
    }
    private func indexPathForScheduleParsor(nowID: NSIndexPath) -> NSIndexPath{ //fron the indexPath used in nowvc to indexpath used in scheduleparsor
        let sec = sectionForScheduleParsor(nowID.section)
        return NSIndexPath(forRow: nowID.row, inSection: sec)
    }
    private func updateLabel(){
        if scheduleParsor.isApplying{
            headerView.nextLabel.text = timeFormatter.stringFromDate(scheduleParsor.nextKeyTime!)
            headerView.scheduleLabel.text = scheduleParsor.schedule?.title
            let work = scheduleParsor.workForDate(NSDate())!
            if work is BreakPart{
                headerView.todayLabel.text = "Break~"
            }else{
                headerView.todayLabel.text = work.title
            }
        }else{
            headerView.nextLabel.text = "N/A"
            headerView.scheduleLabel.text = "No Schedule is Applying!"
            headerView.todayLabel.text = "No work now"
        }
        
    }
    private func cellHeightForPart(part: Part)->CGFloat{
        if part is BreakPart{
            return 44
        }else{
            return  CGFloat( 44 * 3 * Int(part.last) / Int(24 * 3600))
        }
    }
    //MARK: - tableView delegate/ dataSource
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if scheduleParsor == nil {return 0}
        if scheduleParsor.isApplying {
            return 30
        }else{
            return 0
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateFormatter.stringFromDate(scheduleParsor.dateForSection(sectionForScheduleParsor(section)))
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = scheduleParsor.numberOfWorksForIndexPath(NSIndexPath(forRow: 0, inSection: sectionForScheduleParsor(section))){
            return rows
        }else{
            return 0;
        }
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeightForPart(scheduleParsor.workForIndexPath(indexPathForScheduleParsor(indexPath))!)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeightForPart(scheduleParsor.workForIndexPath(indexPathForScheduleParsor(indexPath))!)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let part = scheduleParsor.workForIndexPath(indexPathForScheduleParsor(indexPath))!
        let cell = tableView.dequeueReusableCellWithIdentifier("NowTableCell", forIndexPath: indexPath) as! NowTableCell
        if part is BreakPart{
            cell.title.text = "BreakPart"
            cell.descrip.text = "have a rest~"
        }else{
            cell.title.text = part.title
            cell.descrip.text = part.descriptionIn24h
        }
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
    @IBOutlet weak var nextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        print(spinnerView.frame)
    }
}
class NowTableCell: UITableViewCell{
    
    @IBOutlet weak var colorBar: UIView!
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        colorBar.layer.cornerRadius = 7
        colorBar.backgroundColor = tintColor;
        descrip.textColor = UIColor.grayColor()
    }
}

