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
let kControlImageOffsetStart: CGFloat = 20
let kTranslationRate: CGFloat = 0.25

enum PanDirection {
    case Right, Left, None
}

enum ControlPosition: Int {
    case ControlLeft = 0, ControlCenter, ControlRight
}

struct Control {
    
    var position: ControlPosition
    var imageView: UIImageView
    
    func frame() -> CGRect {
        if let superview = imageView.superview {
            let frame = superview.convertRect(imageView.frame, fromView: imageView.superview)
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
        
        self.controlImages = Array()
        for var index = 0; index < 3; ++index {
            self.controlImages?.append(UIImageView())
        }
        
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
        
        if let imageViews = self.controlImages {
            for (index, value) in enumerate(imageViews) {
                if let image = self.dataSource?.pullForControls?(self, imageForIndex: index) {
                    self.addSubview(value)
                    value.image = image
                    value.frame = CGRectMake(startX + CGFloat(index) * kControlImageOffsetStart - image.size.width/2, self.bounds.size.height/2 + image.size.height/2, image.size.width, image.size.height)
                    value.alpha = 0.0
                }
            }
        }
        
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
        
        if let centerImage = self.controlImages?[1] {
            var bendableCircleFrame = CGRectZero
            var origin = CGPointMake(self.center.x - kBendableViewSize/2, centerImage.center.y - kBendableViewSize/2)
            bendableCircleFrame.size = CGSizeMake(kBendableViewSize, kBendableViewSize)
            bendableCircleFrame.origin = origin
            self.bendableCircle.frame = bendableCircleFrame
            self.bendableCircle.setNeedsDisplay()
            
            self.selectedControl = Control(position: .ControlCenter, imageView: centerImage)
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var ratio = 1 - (scrollView.contentOffset.y + self.bounds.size.height)/(self.bounds.size.height)
        if(scrollView.contentOffset.y < self.bounds.size.height && scrollView.contentOffset.y < 0) {
            animateCenterControl(ratio)
            animateSideControl(ratio, index: 0, direction: -1)
            animateSideControl(ratio, index: 2, direction: 1)
            self.panGesture?.enabled = true
        }
        
        if (scrollView.contentOffset.y < -0.6 * self.bounds.size.height) {
           self.bendableCircle.animateIn()
        } else {
           self.bendableCircle.animateOut()
        }
    }
    
    func animateSideControl(ratio: CGFloat, index: Int, direction: Int) {
        
        if let sideImage = self.controlImages?[index] {
            if (ratio < 1.0) {
                sideImage.alpha = ratio * 1.0
                sideImage.transform = CGAffineTransformMakeTranslation(ratio * CGFloat(direction) * kControlImageEndOffset, 0)
            }
        }
    }
    
    func animateCenterControl(ratio: CGFloat) {
        
        if let centerImage = self.controlImages?[1] {
            centerImage.alpha = ratio * 1.0
            centerImage.transform = CGAffineTransformMakeRotation(ratio * -CGFloat(M_PI * 2))
        }
    }
    
    func pannedInSuperView(recognizer: UIPanGestureRecognizer) {
    
        if recognizer.state == .Changed && self.bendableCircle.state != .Translating {
            
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
                    
                } else if (self.panDirection == .Right) {
                    
                    frame.size.width = self.bendableCircle.frame.size.width + kTranslationRate * translation.x
                    frame.origin.x = self.bendableCircle.frame.origin.x
                    
                } else if (self.panDirection == .Left) {
                    
                    frame.size.width = self.bendableCircle.frame.size.width - kTranslationRate * translation.x
                    frame.origin.x = self.bendableCircle.frame.origin.x + kTranslationRate * translation.x
                }
                
                if frame.size.width < kBendableViewSize {
                    
                        frame.size.width = kBendableViewSize
                        frame.origin.x = self.selectedControl.center().x
                        self.panDirection = .None
                    
                } else if frame.size.width > kBendableWidthThreshold {
                    
                    
                    switch self.panDirection {
                        case .Right:
                                                println("Right")
//                            if let rightImageView = self.controlImages?[2] {
//                                var rightImageViewFrame = self.convertRect(rightImageView.frame, fromView: self)
//                                var center = CGPointMake(rightImageViewFrame.origin.x - rightImageViewFrame.width/2, rightImageViewFrame.origin.y - rightImageViewFrame.height/2)
                                if let control = self.controls?[ControlPosition.ControlRight.rawValue] {
                                    self.selectedControl = control
                                }
                                
                                self.bendableCircle.state = .Translating
                                UIView.animateWithDuration(0.2, animations: {
                                    self.bendableCircle.frame = self.selectedControl.transformToBendableViewFrame()
                                    }, completion: {
                                        (value: Bool) in
                                        self.bendableCircle.state = .Active
                                })
                                
                            }
                        case .Left:
//                            if let leftImageView = self.controlImages?[0] {
//                                var leftImageViewFrame = self.convertRect(leftImageView.frame, fromView: self)
//                                var center = CGPointMake(leftImageViewFrame.origin.x - leftImageViewFrame.width/2, leftImageViewFrame.origin.y - leftImageViewFrame.height/2)
                                if let control = self.controls?[ControlPosition.ControlRight.rawValue] {
                                    self.selectedControl = control
                                }
                                
                                self.bendableCircle.state = .Translating
                                UIView.animateWithDuration(0.2, animations: {
                                    self.bendableCircle.frame = frame
                                    }, completion: {
                                        (value: Bool) in
                                        self.bendableCircle.state = .Active
                                })
                            }
                        default: ()
                    }
                    
                }
                
                self.bendableCircle.frame = frame
            }
        } else if (recognizer.state == .Ended ||
                   recognizer.state == .Cancelled ||
                   recognizer.state == .Failed) {
                    
                    UIView .animateWithDuration(0.2, animations: {
                            var frame = self.bendableCircle.frame
                            frame.size.width = kBendableViewSize
                            frame.size.height = kBendableViewSize
                            frame.origin.x = self.center.x - kBendableViewSize/2
                            self.bendableCircle.frame = frame
                            self.panDirection = .None
                        }, completion: {
                            (value: Bool) in
                    })
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