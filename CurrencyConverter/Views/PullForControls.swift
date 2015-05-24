//
//  PullForControls.swift
//  xCurrency
//
//  Created by Jaikumar Bhambhwani on 5/23/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol PullForControlsDataSource {
    
    optional func pullForControls(pfc: PullForControls, imageForIndex: Int) -> UIImage?
    
}

@objc public protocol PullForControlsDelegate {
    
    optional func didSelectControl(index: Int)
    
}

let kControlImageOffset: CGFloat = 80

public class PullForControls: UIView {
    
    public var delegate: PullForControlsDelegate?
    public var dataSource: PullForControlsDataSource?
    public var panGesture: UIPanGestureRecognizer?
    
    var controlImages: Array<UIImageView>?
    
    lazy var movingLayer: CAShapeLayer = {
            [unowned self] in
            
            let movingLayer = CAShapeLayer()
            movingLayer.bounds = CGRectMake(0, 0, self.bounds.height, self.bounds.height)
            movingLayer.position = self.center
            movingLayer.cornerRadius = self.bounds.height / 2
            movingLayer.fillColor = self.selectedColor.CGColor
            movingLayer.opacity = 0.0
        
            return movingLayer
        }()
    
    var selectedColor: UIColor = UIColor.blueColor() {
        
        didSet {
            self.movingLayer.fillColor = oldValue.CGColor
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
    
    override public func didMoveToSuperview() {
        if let superview = self.superview {
            self.panGesture = UIPanGestureRecognizer(target: self, action: Selector("pannedInSuperView:"))
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
        
        buildSubViews()
    }
    
    func buildSubViews() {
        
        let startX: CGFloat = (self.bounds.size.width / 2.0) - kControlImageOffset
        
        if let imageViews = self.controlImages {
            
            for (index, value) in enumerate(imageViews) {
                if let image = self.dataSource?.pullForControls?(self, imageForIndex: index) {
                    value.image = image
                    value.frame = CGRectMake(startX, 0, image.size.width, image.size.height)
                    value.alpha = 0
                }
            }
        }
        
        self.layer.addSublayer(self.movingLayer)
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let ratio = 1 - (scrollView.contentOffset.y + self.bounds.size.height)/(self.bounds.size.height)
        if(scrollView.contentOffset.y < -0.25 * self.bounds.size.height) {
            animateCenterControl(ratio)
            self.panGesture?.enabled = false
        } else if (scrollView.contentOffset.y < -0.5 * self.bounds.size.height) {
            animateSelectionLayerToFocus()
            animateSideControl(-ratio, index: 0)
            animateSideControl(ratio, index: 1)
            self.panGesture?.enabled = true
        }
    }
    
    func animateSideControl(ratio: CGFloat, index: Int) {
        
        if let sideImage = self.controlImages?[index] {
            
            var opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = sideImage.alpha
            opacityAnim.toValue = NSNumber(float: Float(ratio * 1.0))
            opacityAnim.duration = 0.2
            
            var translateAnim = CABasicAnimation(keyPath: "transform.translation.x")
            translateAnim.fromValue = sideImage.frame.origin.x
            translateAnim.toValue = ratio * kControlImageOffset
            translateAnim.duration = 0.2
            
            var group = CAAnimationGroup()
            group.duration = 0.2
            group.repeatCount = 0
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            group.animations = [opacityAnim, translateAnim]
            
            sideImage.layer.addAnimation(group, forKey: "animateLeftControl")
        }
    }
    
    func animateCenterControl(ratio: CGFloat) {
        
        if let centerImage = self.controlImages?[1] {
            
            var opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = centerImage.alpha
            opacityAnim.toValue = ratio * 1.0
            opacityAnim.duration = 0.2
            
            var rotateAnim = CABasicAnimation(keyPath: "transform.rotation.z")
            rotateAnim.fromValue = atan2(centerImage.transform.b, centerImage.transform.a)
            rotateAnim.toValue = ratio * -kControlImageOffset
            rotateAnim.duration = 0.2
            
            var group = CAAnimationGroup()
            group.duration = 0.2
            group.repeatCount = 0
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            group.animations = [opacityAnim, rotateAnim]
            
            centerImage.layer.addAnimation(group, forKey: "animateLeftControl")
        }
    }
    
    func animateSelectionLayerToFocus() {
        
        var opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0
        opacityAnim.toValue = 1.0
        opacityAnim.duration = 0.2
        
        let startShape = UIBezierPath(roundedRect: CGRectZero, cornerRadius: 0).CGPath
        
        var endFrame: CGRect = CGRectZero
        endFrame.size = CGSizeMake(self.bounds.size.height, self.bounds.size.height)
        endFrame.origin = CGPointMake(self.center.x - self.bounds.size.height/2, self.center.y - self.bounds.size.height/2)
        let endShape = UIBezierPath(roundedRect: endFrame, cornerRadius: self.bounds.size.height/2).CGPath
        
        let pathAnim = CABasicAnimation(keyPath: "path")
        self.movingLayer.path = startShape
        pathAnim.toValue = endShape
        pathAnim.duration = 0.2
        pathAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        pathAnim.fillMode = kCAFillModeBoth
        pathAnim.removedOnCompletion = false
        
        var group = CAAnimationGroup()
        group.duration = 0.2
        group.repeatCount = 0
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.animations = [opacityAnim, pathAnim]
        
        self.movingLayer.addAnimation(group, forKey: "animateLeftControl")
    }
    
    func pannedInSuperView(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .Changed {

        }
    }
}