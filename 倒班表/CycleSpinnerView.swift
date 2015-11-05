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
    func askNewPartWithLengthOf() -> (NSTimeInterval, UIColor)
}
class CycleSpinnerView: UIView {
    var spinnerView: UIView!;
    var radious: CGFloat!
    var partLayers = [PartLayer]();
    var SPINNER_HEIGHT:CGFloat = 44; //parameter
    var delegate: CycleSpinnerViewDelegate?;
    var lengthenPartLayer: PartLayer!

    override init(frame: CGRect) {
        assert(frame.size.width == frame.size.height)
        super.init(frame: frame);
        self.layer.shadowColor = UIColor.blueColor().CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0);
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    //MARK: - Drawing
    override func drawRect(rect: CGRect) {
        /*
        print(bounds.width,bounds.height)
        let radious:CGFloat = (bounds.height / 2)*0.7
        let ctx = UIKit.UIGraphicsGetCurrentContext();
        print("done")
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.0)
        CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0)
        CGContextSetLineWidth(ctx, 5.0)
        CGContextAddEllipseInRect(ctx, CGRectMake(centerPoint.x - radious, centerPoint.y - radious, 2*radious, 2*radious))
        CGContextStrokePath(ctx)*/
        let centerPoint:CGPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        radious = bounds.width * 0.8 / 2
        let path = UIBezierPath(ovalInRect: CGRect(x: centerPoint.x - radious, y: centerPoint.y - radious, width: 2*radious, height: 2*radious))
        path.lineWidth = 20.0;
        UIColor.yellowColor().setStroke()
        path.stroke();

    }
    //MARK: - query
    var bufferLength: CGFloat? {
        get{
            return nil;
        }
    }
    //MARK: - manipulation
    func addPartWithLengthOf(length: NSTimeInterval, color: UIColor){
        let lay = PartLayer(rad: radious, frame: bounds, color:  color)
    }
    func start(){ // show the start animation
        let customLayer = PartLayer(rad: radious, frame: bounds, color: UIColor.yellowColor())
        self.layer.addSublayer(customLayer);
        print("subview added")
        lengthenPartLayer = customLayer;
        doAfterDelay(1.0, closure: {self.lengthenPartPush(15*60)})
    }
    func stop(){ // show stop animation;
        
    }
    func move(seconds: NSTimeInterval){
    }
    //MARK: - frame animation
    var engine: NSTimer?
    var destinationRad: CGFloat = 0.0;
    func lengthenPartPush(ti: NSTimeInterval){
        destinationRad += degreeInSpinner(ti)
        startEngine()
    }
    func updateFrame(){
        if (lengthenPartLayer.lengthenInDegree > destinationRad){
            print("animation done now degree: \(lengthenPartLayer.lengthenInDegree)")
            engine?.invalidate()
            return
        }
        lengthenPartLayer.lengthenInDegree = lengthenPartLayer.lengthenInDegree + CGFloat(0.3);
    }
    //MARK: - utility
    private func degreeInSpinner(length: NSTimeInterval) -> CGFloat{
       return  CGFloat(length)  * 2 * 180 / (3600 * 24);
    }
    private func startEngine(){
        engine = NSTimer(timeInterval: 0.03, target: self, selector: "updateFrame", userInfo: nil, repeats:true)
        NSRunLoop.currentRunLoop().addTimer(engine!, forMode: NSDefaultRunLoopMode)
    }
    
}

class PartLayer: CALayer{
    var color: UIColor
    let LINE_WIDTH: CGFloat = 10.0
    var radious: CGFloat!
    var lengthenInDegree: CGFloat!{
        didSet{
            self.setNeedsDisplay()
        }
    }
    init(rad: CGFloat, frame: CGRect, color: UIColor) {
        self.color = color
        radious = rad;
        super.init();
        self.frame = frame
        shadowOffset = CGSize(width: 3, height: 3)
        shadowOpacity = 1.0
        shadowColor = UIColor.blueColor().CGColor
        delegate = nil
        lengthenInDegree = 0.0
    }
    required init?(coder aDecoder: NSCoder) {
        assert(false)
        color = UIColor.blackColor()
        super.init(coder: aDecoder)
    }
    override func drawInContext(ctx: CGContext) {
        CGContextSaveGState(ctx)
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        CGContextSetLineWidth(ctx, LINE_WIDTH)
        CGContextSetLineCap(ctx, .Round)
        CGContextMoveToPoint(ctx,position.x, position.y - radious)
        CGContextAddArc(ctx, position.x, position.y, radious, -PAI/2, -PAI/2 + degree2Rad(lengthenInDegree), 0)
        //CGContextAddEllipseInRect(ctx, CGRectMake(position.x - radious, position.y - radious, 2*radious, 2*radious))
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
    }
}

