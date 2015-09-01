//
//  NewScheduleVCViewController.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/25.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit
import QuartzCore

class NewScheduleVC: UIViewController {

    
    // MARK: - Properties
    var scheduleToEdit :Schedule!;
    var worksLib: WorksLib!;
    var isRiseUp = true;
    // MARK: - Outlets
    @IBOutlet weak var riseButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var riseUpView: RiseUpView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var riseUpTableView: UITableView!

    // MARK: - Actions
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    @IBAction func moveRiseUpView(sender: AnyObject){
        if let recognizer = sender as? UIGestureRecognizer{
            let position = recognizer.locationInView(riseUpTableView); //taping somewhere else
            let indexPath = riseUpTableView.indexPathForRowAtPoint(position);
            if indexPath != nil {
                return; // cancel move if toucing the riseup cell
            }
        }else{ // tapping the add button
            
        }

        let riser = CABasicAnimation(keyPath: "position")
        riser.removedOnCompletion = false;
        riser.fillMode = kCAFillModeForwards;
        riser.duration = 0.3;
        riser.fromValue = NSValue(CGPoint: riseUpView.center)
        if isRiseUp {
            riser.toValue = NSValue(CGPoint: CGPoint(x: riseUpView.center.x, y: riseUpView.center.y - 176));
            riser.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        }else{
            riser.toValue = NSValue(CGPoint: CGPoint(x: riseUpView.center.x, y: riseUpView.center.y + 176));
            riser.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        }
        riser.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        riser.delegate = self;
        riseUpView.layer.addAnimation(riser, forKey: "riseUpViewMove");
    }

    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if isRiseUp {
            riseUpView.layer.removeAllAnimations();
            riseUpView.center.x = view.bounds.width / 2;
            riseUpView.center.y = view.bounds.height - (riseUpView.bounds.height / 2);
            isRiseUp = false;
            riseButton.enabled = false;
            let rec = UITapGestureRecognizer(target: self, action: Selector("moveRiseUpView:"))
            rec.cancelsTouchesInView = false;
            rec.delegate = self
            view.addGestureRecognizer(rec);
        }else{
            riseUpView.layer.removeAllAnimations();
            riseUpView.frame.origin.x = 0;
            riseUpView.frame.origin.y = view.bounds.height - 44;
            isRiseUp = true;
            riseButton.enabled = true;
            let rec = view.gestureRecognizers?[0] as! UITapGestureRecognizer;
            view.removeGestureRecognizer(rec);
        }
    }
    // MARK: - View;
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        let button2 = toolBar.items?[1] as! UIBarButtonItem;
        button2.width = (view.bounds.width - 88) //the width of the trash item is 44!
        if scheduleToEdit == nil {
            scheduleToEdit = Schedule();
        }
        riseUpView.worksLib = worksLib;
        riseUpView.delegate = self;
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
extension NewScheduleVC :UITableViewDelegate{
    
}
extension NewScheduleVC :UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return scheduleToEdit.parts.count;
        return scheduleToEdit.parts.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let cell2 = tableView.dequeueReusableCellWithIdentifier("worksArrangementCell") as? UITableViewCell {
            cell = cell2;
        }else {
            cell =  UITableViewCell(style: .Value1, reuseIdentifier: "worksArrangementCell");
        }
        let id = indexPath.row;
        cell.textLabel?.text = scheduleToEdit.parts[id].title;
        cell.detailTextLabel?.text = "hola";
        return cell;
    }
}

extension NewScheduleVC: UINavigationBarDelegate{ //deal with the status bar
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension NewScheduleVC: UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let views = riseUpView.subviews as! [UIView];
        if let ok = find(views, touch.view) {
            return false
        }else{
            return true;
        }
        
    }
}

extension NewScheduleVC: RiseUpViewDelegate {
    func riseUpViewDidSelectId(indexPath: NSIndexPath) {
        let id = indexPath.row;
        scheduleToEdit.parts.append(worksLib.lib[id]);
        let idToInsert = NSIndexPath(forRow: scheduleToEdit.parts.count - 1, inSection: 0)
        println("did insert schedule at \(id)")
        tableView.insertRowsAtIndexPaths([idToInsert], withRowAnimation: .Fade)
        println("shoudld insert row at \(idToInsert.row)");
    }
}