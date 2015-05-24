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

enum SelectionLayerState {
    case Activated, Selecting, Selected, Deactivated
}

let kControlImageEndOffset: CGFloat = 100
let kControlImageOffsetStart: CGFloat = 20
let kSelectionLayerSize: CGFloat = 65

public class PullForControls: UIView {
    
    public var delegate: PullForControlsDelegate?
    public var dataSource: PullForControlsDataSource? {
        didSet {
           buildSubViews()
        }
    }
    public var panGesture: UIPanGestureRecognizer?
    
    var controlImages: Array<UIImageView>?
    
    lazy var movingLayer: CAShapeLayer = {
            [unowned self] in
            
            let movingLayer = CAShapeLayer()
            movingLayer.cornerRadius = self.bounds.height / 2
            movingLayer.fillColor = self.selectedColor.CGColor
            movingLayer.opacity = 0.0
            return movingLayer
        }()
    
    var selectedColor: UIColor = UIColor.blueColor() {
        
        didSet {
            self.movingLayer.fillColor = self.selectedColor.CGColor
        }
    }
    
    var state: SelectionLayerState = .Deactivated {
        
        willSet {
            
            if(newValue != state) {
                switch(newValue) {
                    case .Activated:
                        animateSelectionLayer(true)
                    case .Deactivated:
                        animateSelectionLayer(false)
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
    }
    
    func buildSubViews() {
        
        self.layer.addSublayer(self.movingLayer)
        
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
            self.state = .Activated
        } else {
            self.state = .Deactivated
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
    
    func animateSelectionLayer(activate: Bool) {
        
        if let centerImage = self.controlImages?[1] {
            var opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = activate ? 0 : 1
            opacityAnim.toValue = activate ? 1 : 0
            opacityAnim.duration = 1
            
            var startShape: CGPath
            var endShape: CGPath
            
            if activate {
                
                startShape = UIBezierPath(roundedRect: centerImage.frame, cornerRadius: centerImage.frame.size.height/2).CGPath
                var endFrame: CGRect = centerImage.frame
                endFrame.size = CGSizeMake(kSelectionLayerSize, kSelectionLayerSize)
                endFrame.origin = CGPointMake(centerImage.center.x - kSelectionLayerSize/2, centerImage.center.y - kSelectionLayerSize/2)
                endShape = UIBezierPath(roundedRect: endFrame, cornerRadius: kSelectionLayerSize/2).CGPath
                
                
            } else {
                
                startShape = UIBezierPath(roundedRect: self.movingLayer.frame, cornerRadius: self.movingLayer.frame.size.height/2).CGPath
                var endFrame: CGRect = centerImage.frame
                endFrame.size = CGSizeZero
                endFrame.origin = CGPointZero
                endShape = UIBezierPath(roundedRect: endFrame, cornerRadius: kSelectionLayerSize/2).CGPath
                
            }
            
            let pathAnim = CABasicAnimation(keyPath: "path")
            self.movingLayer.path = startShape
            pathAnim.toValue = endShape
            pathAnim.duration = 0.25
            pathAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
            pathAnim.removedOnCompletion = false
            
            var group = CAAnimationGroup()
            group.duration = 0.25
            group.repeatCount = 0
            group.fillMode = kCAFillModeBoth
            group.removedOnCompletion = false
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            group.animations = [opacityAnim, pathAnim]
            
            self.movingLayer.addAnimation(group, forKey: "animateLeftControl")
        }
    }
    
    func pannedInSuperView(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .Changed {

        }
    }
}