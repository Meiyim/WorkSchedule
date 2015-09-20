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
    weak var dataLib: DataLib!{
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
        return dataLib.worksLib.count;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell;
        if let cell2 = riseUpTableView.dequeueReusableCellWithIdentifier("worksCell") {
            cell = cell2;
        }else{
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "worksCell");
        }
        let id = indexPath.row;
        cell.textLabel?.text = dataLib.worksLib[id].title;
        cell.detailTextLabel?.text = dataLib.worksLib[id].descriptionIn24h;
        return cell
    }
}

