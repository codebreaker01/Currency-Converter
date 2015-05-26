//
//  BendableCircle.swift
//  xCurrency
//
//  Created by Jaikumar Bhambhwani on 5/24/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import UIKit

let kBendableViewSize: CGFloat = 60.0
let kBendableWidthThreshold: CGFloat = 80.0

enum BendableCircleState {
    case Active, InActive, Translating
}

class BendableCircle: UIView {
    
    var state: BendableCircleState = .InActive {
        willSet {
            
            if(newValue != state) {
                
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
    
    override func drawRect(rect: CGRect) {
        drawBendableCircle(frame: self.bounds)
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

    func animateIn() {
        
        UIView.animateWithDuration(0.35) {
            self.alpha = 1.0
        }
    }
    
    func animateOut() {
        
        UIView.animateWithDuration(0.25) {
            self.alpha = 0.0
        }
    }

}
