//
//  PullForControls.swift
//  xCurrency
//
//  Created by Jaikumar Bhambhwani on 5/23/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import UIKit

let kControlImageEndOffset: CGFloat = 100
let kControlImageOffsetStart: CGFloat = 30
let kTranslationRate: CGFloat = 0.35

enum PanDirection {
    case Right, Left, ReCalculcate, None
    
    var description : String {
        
        switch self {
            case .Right:            return "Right"
            case .Left:             return "Left"
            case .ReCalculcate :    return "ReCalculcate"
            case .None:             return "None"
        }
    }
}

enum ControlPosition: Int {
    case ControlLeft = 0, ControlCenter, ControlRight
    
    func next(direction: PanDirection) -> ControlPosition {
        
        var next: ControlPosition = self
        switch(self) {
            
            case .ControlLeft:
                if(direction == .Right) {
                    next = .ControlCenter
                }
            case .ControlCenter:
                if(direction == .Right) {
                     next = .ControlRight
                } else if(direction == .Left) {
                    next = .ControlLeft
                }
            case .ControlRight:
                if(direction == .Left) {
                    next = .ControlCenter
                }
            default: ()
            
        }
        return next
    }
    
    var description : String {
        
        switch self {
            case .ControlLeft:      return "ControlLeft";
            case .ControlCenter:    return "ControlCenter";
            case .ControlRight:     return "ControlRight";
        }
        
    }
}

struct Control {
    
    var position: ControlPosition
    var imageView: UIImageView
    
    func frame() -> CGRect {
        if let superview = imageView.superview {
            let frame = superview.convertRect(imageView.frame, fromView: superview)
            return frame
        }
        return CGRectZero
    }
    
    func center() -> CGPoint {
        return CGPointMake(CGRectGetMidX(frame()), CGRectGetMidY(frame()))
    }
    
    func transformToBendableViewFrame() -> CGRect {
        return CGRectMake(center().x - kBendableViewSize/2, center().y - kBendableViewSize/2, kBendableViewSize, kBendableViewSize)
    }
}

@objc public protocol PullForControlsDataSource {
    optional func pullForControls(pfc: PullForControls, imageForIndex: Int) -> UIImage?
}

@objc public protocol PullForControlsDelegate {
    optional func didSelectControl(index: Int)
}

public class PullForControls: UIView, UIGestureRecognizerDelegate {
    
    public var delegate: PullForControlsDelegate?
    public var dataSource: PullForControlsDataSource? {
        didSet {
           buildSubViews()
        }
    }
    public var panGesture: UIPanGestureRecognizer!
    
    var controlImages: Array<UIImageView>?
    var controls: Array<Control>?
    var panDirection: PanDirection = .None
    var selectedControl: Control = Control(position: .ControlCenter, imageView: UIImageView())
    
    var selectedColor: UIColor? {
        
        didSet {

        }
    }
    
    var bendableCircle: BendableCircle =  {
        
        var circle: BendableCircle = BendableCircle(frame: CGRectZero)
        circle.backgroundColor = UIColor.clearColor()
        return circle
    
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public func didMoveToSuperview() {
        
        if let superview = self.superview {
            self.panGesture = UIPanGestureRecognizer(target: self, action: Selector("pannedInSuperView:"))
            self.panGesture.delegate = self
            superview.addGestureRecognizer(self.panGesture)
        }
    }
    
    func commonInit() {
        
        var frame = self.frame
        frame.origin.y = -frame.size.height
        self.frame = frame
        
        self.controls = Array()
        for var index = 0; index < 3; ++index {
            if let position = ControlPosition(rawValue:index) {
                self.controls?.append(Control(position: position, imageView: UIImageView()))
            }
        }
        
        self.selectedColor = UIColor(rgba: "#34D6F5")
    }
    
    func buildSubViews() {
        
        self.addSubview(self.bendableCircle)
        self.bendableCircle.alpha = 0.0
        
        let startX: CGFloat = self.center.x - kControlImageOffsetStart
        
        for var index = 0; index < self.controls?.count; index++ {
            if let position = ControlPosition(rawValue:index) {
                var control = self.controls?[index]
                if let image = self.dataSource?.pullForControls?(self, imageForIndex: index) {
                    if let imageView = control?.imageView {
                        self.addSubview(imageView)
                        imageView.image = image
                        imageView.frame = CGRectMake(startX + CGFloat(index) * kControlImageOffsetStart - image.size.width/2, self.bounds.size.height/2 + image.size.height/2, image.size.width, image.size.height)
                        imageView.alpha = 0.0
                    }
                }
            }
        }
        
        if let centerControl = self.controls?[1] {
            var bendableCircleFrame = CGRectZero
            var origin = CGPointMake(self.center.x - kBendableViewSize/2, centerControl.center().y - kBendableViewSize/2)
            bendableCircleFrame.size = CGSizeMake(kBendableViewSize, kBendableViewSize)
            bendableCircleFrame.origin = origin
            self.bendableCircle.frame = bendableCircleFrame
            self.bendableCircle.setNeedsDisplay()
            
            self.selectedControl = centerControl
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var ratio = 1 - (scrollView.contentOffset.y + self.bounds.size.height)/(self.bounds.size.height)
        if(scrollView.contentOffset.y < self.bounds.size.height && scrollView.contentOffset.y < 0) {
            animateCenterControl(ratio)
            animateSideControl(ratio, index: 0, direction: -1)
            animateSideControl(ratio, index: 2, direction: 1)
            animateBendingLayer(ratio)
            self.panGesture?.enabled = true
        }
        
        if(scrollView.contentOffset.y == 0) {
            
            if let centerControl = self.controls?[1] {
                var bendableCircleFrame = CGRectZero
                var origin = CGPointMake(centerControl.center().x - kBendableViewSize/2, centerControl.center().y - kBendableViewSize/2)
                bendableCircleFrame.size = CGSizeMake(kBendableViewSize, kBendableViewSize)
                bendableCircleFrame.origin = origin
                self.bendableCircle.frame = bendableCircleFrame
                self.bendableCircle.setNeedsDisplay()
                self.selectedControl.position = .ControlCenter
            }
        }
    }
    
    func animateBendingLayer(ratio: CGFloat) {
        
        if (ratio < 1.0) {
            if(self.bendableCircle.state == .Active) {
                UIView.animateWithDuration(0.2, animations: {
                    self.bendableCircle.alpha = 0.0
                    self.bendableCircle.state = .InActive
                    }, completion:{
                        (value: Bool) in
                        if(self.selectedControl.position == .ControlRight || self.selectedControl.position == .ControlLeft) {
                            self.bendableCircle.center = self.selectedControl.center()
                        }
                })
            }
        } else {
            if(self.bendableCircle.state == .InActive) {
                UIView.animateWithDuration(0.25) {
                    self.bendableCircle.alpha = 1.0
                    self.bendableCircle.state = .Active
                }
            }
        }
    }
    
    func animateSideControl(ratio: CGFloat, index: Int, direction: Int) {
        
        if let sideControl = self.controls?[index] {
            if (ratio > 1.0) {
                
                UIView.animateWithDuration(0.75) {
                    sideControl.imageView.alpha = 1.0
                }
                UIView.animateWithDuration(0.25) {
                    sideControl.imageView.transform = CGAffineTransformMakeTranslation(CGFloat(direction) * kControlImageEndOffset, 0)
                }
                
            } else {
                
                UIView.animateWithDuration(0.25) {
                    sideControl.imageView.alpha = 0.0
                }
                UIView.animateWithDuration(0.75) {
                       sideControl.imageView.transform = CGAffineTransformMakeTranslation(-1.0 * CGFloat(direction) * kControlImageOffsetStart, 0)
                }
            }
        }
    }
    
    func animateCenterControl(ratio: CGFloat) {
        
        if let centerControl = self.controls?[1] {
                centerControl.imageView.alpha = ratio * 1.0
                centerControl.imageView.transform = CGAffineTransformMakeRotation(ratio * -CGFloat(M_PI * 2))
        }
    }
    
    func pannedInSuperView(recognizer: UIPanGestureRecognizer) {
    
        if recognizer.state == .Changed && self.bendableCircle.state == .Active {
            
            if let superview = self.superview {
                
                var translation = recognizer.translationInView(superview)
                var velocity = recognizer.velocityInView(superview)
                recognizer.setTranslation(CGPointZero, inView: superview)
                
                var frame = self.bendableCircle.frame
                
                if (self.panDirection == .None) {
                    
                    if (velocity.x > 0) {
                        frame.size.width = self.bendableCircle.frame.size.width + kTranslationRate * translation.x
                        frame.origin.x = self.bendableCircle.frame.origin.x
                        self.panDirection = .Right
                    } else {
                        frame.size.width = self.bendableCircle.frame.size.width - kTranslationRate * translation.x
                        frame.origin.x = self.bendableCircle.frame.origin.x + kTranslationRate * translation.x
                        self.panDirection = .Left
                    }
                    
                } else if (self.panDirection == .ReCalculcate){
                    
                    if (velocity.x > 0) {
                        self.panDirection = .Right
                    } else {
                        self.panDirection = .Left
                    }
                    
                } else if (self.panDirection == .Right && self.selectedControl.position != .ControlRight) {
                    
                    frame.size.width = self.bendableCircle.frame.size.width + kTranslationRate * translation.x
                    frame.origin.x = self.bendableCircle.frame.origin.x
                    
                } else if (self.panDirection == .Left && self.selectedControl.position != .ControlLeft) {
                    
                    frame.size.width = self.bendableCircle.frame.size.width - kTranslationRate * translation.x
                    frame.origin.x = self.bendableCircle.frame.origin.x + kTranslationRate * translation.x
                } else {
                    
                    self.panDirection = .ReCalculcate
                }
                
                self.bendableCircle.frame = frame
                self.bendableCircle.setNeedsDisplay()
                
                if frame.size.width < kBendableViewSize {
                    
                        frame.size.width = kBendableViewSize
                        frame.origin.x = self.selectedControl.center().x
                        self.panDirection = .None
                    
                } else if frame.size.width > kBendableWidthThreshold {
                    
                    var nextPosition = self.selectedControl.position.next(self.panDirection)
                    if let control = self.controls?[nextPosition.rawValue] {
                        self.selectedControl = control
                    }
                    
                    var previousState = self.bendableCircle.state
                    self.bendableCircle.state = .Translating
                    UIView.animateWithDuration(0.2, animations: {
                        self.bendableCircle.frame = self.selectedControl.transformToBendableViewFrame()
                        }, completion: {
                            (value: Bool) in
                            self.bendableCircle.state = previousState
                    })
                }
            }
            
        } else if (recognizer.state == .Ended ||
                   recognizer.state == .Cancelled ||
                   recognizer.state == .Failed) {
                    
               
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}