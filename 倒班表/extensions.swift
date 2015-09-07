//
//  extensions.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/9/6.
//  Copyright (c) 2015年 陈徐屹. All rights reserved.
//

import Foundation
import UIKit

extension NSTimeInterval {
    var formattedString: String{
        assert(self < 3600*24*2, "Time Interval should less than 24h")
        var time = self;
        if time > 3600*24 {time -= 3600*24.0}
        let h: Int = Int(time / 3600);
        let min: Int = Int(time % 3600 / 60);
        let str = String(format: "%2d : %02d", h, min)
        return str;
    }
}