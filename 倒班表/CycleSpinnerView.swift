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
    var lengthenPartLayer: CALayer!
    var layerDrawer: PartLayerDrawer!
    

    override init(frame: CGRect) {
        assert(frame.size.width == frame.size.height)
        super.init(frame: frame);
        prepare()

    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        assert(frame.width == frame.height)
        prepare()
    }
    private func prepare(){
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        radious = bounds.width * 0.8 / 2
        lengthenPartLayer = CALayer();
        lengthenPartLayer.frame = self.bounds
        layerDrawer = PartLayerDrawer(pos: lengthenPartLayer.position, radious: radious)
        lengthenPartLayer.delegate = layerDrawer
        lengthenPartLayer.shouldRasterize = true;
        
        self.layer.addSublayer(lengthenPartLayer)
        self.layer.shadowColor = UIColor.blueColor().CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSize(width: -2.0, height: 4.0);
        engine =  CADisplayLink(target: self, selector: Selector("updateFrame"))
    }
    //MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        let centerPoint:CGPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(x: centerPoint.x - radious, y: centerPoint.y - radious, width: 2*radious, height: 2*radious))
        //let path = UIBezierPath(arcCenter: centerPoint, radius: radious, startAngle: 0, endAngle: 1.8, clockwise: true)
        path.lineWidth = 20.0;
        UIColor.yellowColor().setStroke()
        path.stroke();
        

    }
    
    //MARK: - manipulation

    func start(){ // show the start
        while(bufferLength < 360){
            addPart()
        }
        move(3600*24, speed:  9.0)
    }
    func stop(){ // show stop animation;
        
    }
    func move(seconds: NSTimeInterval, speed: CGFloat){
        self.speed = speed
        destinationRad = degreeInSpinner(seconds)
        startEngine()
    }
    //MARK: - frame animation
    var engine: CADisplayLink!
    var destinationRad: CGFloat = 0.0;
    var speed: CGFloat = 1.0 // speed in degree
    var count = 0;
    //var last = CFAbsoluteTimeGetCurrent();  //used to observe fps
    func updateFrame(){
        //let now = CFAbsoluteTimeGetCurrent();
        //print("frame count: \(count++) involk timeInterval\(now - last)")
        //last = now;
        if(bufferLength < 5){
            addPart();
        }
        if layerDrawer.arcs.isEmpty {
            engine.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            print("animation stop because no sublayers")
            return
        }
        destinationRad -= speed
        layerDrawer.proceed(speed)
        lengthenPartLayer.setNeedsDisplay()
        if destinationRad <= 0 {
            engine.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
    }
    private func addPart()->Bool{ //asking the delegate for the property once
        guard let tup = delegate?.propertyOfNewPartInCycleSpinnerView(self) else{ return false }
        let arc = ArcInLayer(headAngel: 270+bufferLength, length: degreeInSpinner(tup.0), color: tup.1, alpha: 0.0)
        layerDrawer.arcs.insert(arc, atIndex: 0)
        print("subview added")
        return true;
    }
    var bufferLength: CGFloat {
        get{
            guard let lay = layerDrawer.arcs.first else {return 0}
            return lay.headAngel + lay.length - 270
        }
    }
    //MARK: - utility
    private func degreeInSpinner(length: NSTimeInterval) -> CGFloat{
       return  CGFloat(length)  * 2 * 180 / (3600 * 24);
    }
    private func startEngine(){
        engine.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)

    }
    
}
struct ArcInLayer{
    var headAngel:CGFloat
    var length: CGFloat
    var color: UIColor
    var alpha: CGFloat
}
class PartLayerDrawer: NSObject{
    let LINE_WIDTH: CGFloat = 12.0
    let offset: CGSize = CGSize(width: -3, height: 3)
    var position: CGPoint!
    var radious: CGFloat!
    var arcs = [ArcInLayer]();
    init(pos: CGPoint, radious: CGFloat) {
        position = pos
        self.radious = radious
    }
    func proceed(deg: CGFloat){ //headAngel varient from 270 -----> -90 -------> -90-length
        for(var i = 0; i < arcs.count; ++i) {
            if(arcs[i].headAngel - deg < -90){ //headAngel - deg is the head position after proceed
                arcs[i].headAngel = -90;
                arcs[i].length =  arcs[i].headAngel - deg + arcs[i].length - (-90)
            }else{
                arcs[i].headAngel -= deg//rotation
            }
            if(arcs[i].headAngel < 270 && arcs[i].headAngel > 270 - 60){ //gradient zone 270 ---> 210
                arcs[i].alpha = (270-arcs[i].headAngel)/60
            }else if (arcs[i].headAngel < 270 - 60){
                arcs[i].alpha = 1.0
            }
            if(arcs[i].headAngel + arcs[i].length < -90){
                arcs.removeAtIndex(i)
                print("arc removed")
            }
        }
    }
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        for(var i=0; i != arcs.count ; ++i){
            let rad = degree2Rad(arcs[i].headAngel)
            CGContextSaveGState(ctx)
            //CGContextSetShouldAntialias(ctx, true)
            CGContextSetAllowsAntialiasing(ctx, true)
            CGContextSetShadowWithColor(ctx, offset, 3, UIColor.blackColor().CGColor)
            CGContextSetStrokeColorWithColor(ctx, arcs[i].color.colorWithAlphaComponent(arcs[i].alpha).CGColor)
            CGContextSetLineWidth(ctx, LINE_WIDTH)
            CGContextSetLineCap(ctx, .Round)
            CGContextMoveToPoint(ctx,position.x + radious*cos(rad), position.y + radious*sin(rad))
            CGContextAddArc(ctx, position.x, position.y, radious, rad ,  rad + degree2Rad(arcs[i].length), 0)
            //CGContextAddEllipseInRect(ctx, CGRectMake(position.x - radious, position.y - radious, 2*radious, 2*radious))
            CGContextStrokePath(ctx)
            CGContextRestoreGState(ctx)
        }
    }

}

