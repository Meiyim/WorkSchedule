//
//  RiseUpVC.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/8/28.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import UIKit

protocol RiseUpViewDelegate {
    func riseUpViewDidSelectId(id: NSIndexPath)
}


class RiseUpView:UIView, UITableViewDelegate {
    var worksLib = WorksLib(){
        didSet{
            riseUpTableView.reloadData();
        }
    }
    var delegate: RiseUpViewDelegate?;
    @IBOutlet weak var riseUpTableView: UITableView!
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        riseUpTableView.deselectRowAtIndexPath(indexPath, animated: true);
        delegate?.riseUpViewDidSelectId(indexPath);
    }
}

extension RiseUpView: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return worksLib.lib.count;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "worksCell");
        let id = indexPath.row;
        cell.textLabel?.text = worksLib.lib[id].title;
        return cell
    }
}

