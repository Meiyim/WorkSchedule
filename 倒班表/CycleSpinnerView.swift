//
//  CycleSpinnerView.swift
//  倒班表
//
//  Created by 陈徐屹 on 15/10/9.
//  Copyright © 2015年 陈徐屹. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics
protocol CycleSpinnerViewDelegate: class{
    func propertyOfNewPartInCycleSpinnerView(cycleSpinnerView: CycleSpinnerView)->(NSTimeInterval,UIColor)
}
class CycleSpinnerView: UIView {
    var spinnerView: UIView!;
    var radious: CGFloat!
    var SPINNER_HEIGHT:CGFloat = 44; //parameter
    var delegate: CycleSpinnerViewDelegate?;
    var lengthenPartLayer: PartLayer!
    

    override init(frame: CGRect) {
        assert(frame.size.width == frame.size.height)
        super.init(frame: frame);
        self.layer.shadowColor = UIColor.blueColor().CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSize(width: -2.0, height: 4.0);
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    //MARK: - Drawing
    override func drawRect(rect: CGRect) {
        let centerPoint:CGPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        radious = bounds.width * 0.8 / 2
        let path = UIBezierPath(ovalInRect: CGRect(x: centerPoint.x - radious, y: centerPoint.y - radious, width: 2*radious, height: 2*radious))
        path.lineWidth = 20.0;
        UIColor.yellowColor().setStroke()
        path.stroke();

    }
    //MARK: - manipulation

    func start(){ // show the start
        addPart()
        move(3600*24, speed:  10.0)
    }
    func stop(){ // show stop animation;
        
    }
    func move(seconds: NSTimeInterval, speed: CGFloat){
        self.speed = speed
        destinationRad = degreeInSpinner(seconds)
        startEngine()
    }
    //MARK: - frame animation
    var engine: NSTimer?
    var destinationRad: CGFloat = 0.0;
    var speed: CGFloat = 1.0 // speed in degree
    var count = 0;
    var last = CFAbsoluteTimeGetCurrent();
    func updateFrame(){
        let now = CFAbsoluteTimeGetCurrent();
        print("frame count: \(count++) involk timeInterval\(now - last)")
        last = now;
        if(bufferLength < 5){
            addPart();
        }
        guard let layers = self.layer.sublayers as? [PartLayer] else {
            engine?.invalidate()
            print("animation stop because no sublayers")
            return
        }
        destinationRad -= speed
        for lay in layers {
            lay.proceed(speed)
            if !lay.isValid {
                lay.removeFromSuperlayer();
            }else{
                lay.setNeedsDisplay()
            }
        }

        if destinationRad < 0 {
            engine?.invalidate()
            print("engine is out")
        }
    }
    private func addPart()->Bool{ //asking the delegate for the property once
        guard let tup = delegate?.propertyOfNewPartInCycleSpinnerView(self) else{ return false }
        let lay = PartLayer(rad: radious, frame: bounds,length: degreeInSpinner(tup.0), posi: bufferLength , color:  tup.1)
        lay.drawsAsynchronously = true;
        layer.insertSublayer(lay, atIndex: 0)
        print("subview added")
        return true;
    }
    var bufferLength: CGFloat {
        get{
            guard let lay = self.layer.sublayers?.first as? PartLayer else{return 0}
            return lay.headAngel + lay.lengthenInDegree - 270
        }
    }
    //MARK: - utility
    private func degreeInSpinner(length: NSTimeInterval) -> CGFloat{
       return  CGFloat(length)  * 2 * 180 / (3600 * 24);
    }
    private func startEngine(){
        engine = NSTimer(timeInterval: 0.016, target: self, selector: Selector("updateFrame"), userInfo: nil, repeats:true)
        engine?.tolerance = 0.005
        NSRunLoop.currentRunLoop().addTimer(engine!, forMode: NSDefaultRunLoopMode)
    }
    
}

class PartLayer: CALayer{
    var color: UIColor
    let LINE_WIDTH: CGFloat = 10.0
    var radious: CGFloat!
    var isValid = false;
    var headAngel: CGFloat = 270 /*{
        
        didSet{
            if(isValid && headAngel > -89.9){
                self.setNeedsDisplay();
            }
        }
    }*/
    var lengthenInDegree: CGFloat = 0.0 /*{
        didSet{
            if(lengthenInDegree < 0.0){
                isValid = false
            }
            if(isValid){
                self.setNeedsDisplay()
            }
        }
    }*/
    init(rad: CGFloat, frame: CGRect, length: CGFloat, posi: CGFloat, color: UIColor) {
        self.color = color
        radious = rad;
        lengthenInDegree = length;
        super.init();
        headAngel += posi
        self.frame = frame
        shadowOffset = CGSize(width: -2, height: 4)
        shadowOpacity = 1.0
        //shadowColor = UIColor.blueColor().CGColor
        delegate = nil
        isValid = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        assert(false)
        color = UIColor.blackColor()
        super.init(coder: aDecoder)
    }
    func proceed(deg: CGFloat){ //headAngel varient from 270 -----> -90 -------> -90-length

        if(headAngel - deg < -90){ //headAngel - deg is the head position after proceed
            headAngel = -90;
            lengthenInDegree =  headAngel - deg + lengthenInDegree - (-90)
        }else{
            headAngel -= deg//rotation
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        if(headAngel > 270){
            self.opacity = 0
        }else if(headAngel > 270 - 90){ //adjust opacity gradient zone of 20 degree!!
            self.opacity = Float( (270 - headAngel) / CGFloat(90) )
        }else{
            self.opacity = 1.0
        }
        CATransaction.commit();
    }
    override func drawInContext(ctx: CGContext) {
        
        //print("draw Layer\(headAngel)")
        let rad = degree2Rad(headAngel)
        CGContextSaveGState(ctx)
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        CGContextSetLineWidth(ctx, LINE_WIDTH)
        CGContextSetLineCap(ctx, .Round)
        CGContextMoveToPoint(ctx,position.x + radious*cos(rad), position.y + radious*sin(rad))
        CGContextAddArc(ctx, position.x, position.y, radious, degree2Rad(headAngel),  degree2Rad(headAngel + lengthenInDegree), 0)
        //CGContextAddEllipseInRect(ctx, CGRectMake(position.x - radious, position.y - radious, 2*radious, 2*radious))
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
        
    }
}

