//
//  CurrencyConverter.swift
//  xCurrency
//
//  Created by Jaikumar Bhambhwani on 5/24/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import UIKit

enum BendableState {
    case Active, InActive, Bending
}

let kSelectionLayerSize: CGFloat = 65

private class BendableLayer: CAShapeLayer {
    
    var state: BendableState?
    
    func animate(activate: Bool, refFrame:CGRect) {
        
        var opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = activate ? 0 : 1
        opacityAnim.toValue = activate ? 1 : 0
        opacityAnim.speed = 0.5
        opacityAnim.fillMode = kCAFillModeBoth
        
        var startShape: CGPath
        var endShape: CGPath
        
        if activate {
            
            startShape = UIBezierPath(roundedRect: refFrame, cornerRadius: refFrame.size.height/2).CGPath
            var endFrame: CGRect = refFrame
            endFrame.size = CGSizeMake(kSelectionLayerSize, kSelectionLayerSize)
            endFrame.origin = CGPointMake((refFrame.origin.x + refFrame.width/2) - kSelectionLayerSize/2, (refFrame.origin.y + refFrame.height/2) - kSelectionLayerSize/2)
            endShape = UIBezierPath(roundedRect: endFrame, cornerRadius: kSelectionLayerSize/2).CGPath
            
            
        } else {
            
            startShape = UIBezierPath(roundedRect: refFrame, cornerRadius: refFrame.size.height/2).CGPath
            var endFrame: CGRect = refFrame
            endFrame.size = CGSizeZero
            endFrame.origin = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
            endShape = UIBezierPath(roundedRect: endFrame, cornerRadius: kSelectionLayerSize/2).CGPath
        }
        
        let pathAnim = CABasicAnimation(keyPath: "path")
        self.path = startShape
        pathAnim.toValue = endShape
        pathAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        pathAnim.removedOnCompletion = false
        
        var group = CAAnimationGroup()
        group.duration = 0.75
        group.speed = activate ? 1.0 : 4.0
        group.repeatCount = 0
        group.fillMode = kCAFillModeBoth
        group.removedOnCompletion = false
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.animations = [opacityAnim, pathAnim]
        
        self.addAnimation(group, forKey: "animateLeftControl")
    }
}

public class BendableView : UIView {
    
    private var bendableLayer: BendableLayer?
    
    var state: BendableState = .InActive {
        
        willSet {
            
            if(newValue != state) {
                
                self.bendableLayer?.state = newValue
                
                switch(newValue) {
                case .Active:
                    animateIn()
                case .InActive:
                    animateOut()
                default: ()
                    
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
//        self.bendableLayer = self.layer as? BendableLayer
    }
    
    public var layerFillColor: UIColor? {
        didSet {
            self.bendableLayer?.fillColor = self.layerFillColor?.CGColor
        }
    }
    
    public override var frame: CGRect {
        willSet {
            self.setNeedsDisplay()
        }
    }
    
    public func animateIn() {
        self.bendableLayer?.animate(true, refFrame: self.bounds)
    }
    
    public func animateOut() {
        self.bendableLayer?.animate(false, refFrame: self.bounds)
    }
    
//    override public class func layerClass() -> AnyClass {
//        return BendableLayer.self
//    }
    
    override public func  drawRect(rect: CGRect) {
            drawBendableCircle(frame: self.frame)
    }
    
    func drawBendableCircle(#frame: CGRect) {
        
        var ovalPath = UIBezierPath()
        ovalPath.moveToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.50000 * frame.height))
        ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.22386 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.77614 * frame.width, frame.minY + 0.00000 * frame.height))
        ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.50000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.22386 * frame.width, frame.minY + 0.00000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.22386 * frame.height))
        ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 1.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.77614 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.22386 * frame.width, frame.minY + 1.00000 * frame.height))
        ovalPath.addCurveToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.50000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.77614 * frame.width, frame.minY + 1.00000 * frame.height), controlPoint2: CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.77614 * frame.height))
        ovalPath.closePath()
        UIColor.grayColor().setFill()
        ovalPath.fill()
    }
}