//
//  GraphView.swift
//  Calculator
//
//  Created by nevercry on 9/21/15.
//  Copyright © 2015 nevercry. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func y(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    var origin: CGPoint {
        get {
            var origin = originRelativeToCenter
            if geometryReady {
                origin.x += center.x
                origin.y += center.y
            }
            return origin
        }
        set {
            var origin = newValue
            if geometryReady {
                origin.x -= center.x
                origin.y -= center.y
            }
            originRelativeToCenter = origin
        }
        // 把原点与中心点对应
    }
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    private var originRelativeToCenter: CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    private var geometryReady = false
    
    override func drawRect(rect: CGRect) {
        if !geometryReady && originRelativeToCenter != CGPointZero {
            let originHelper = origin
            geometryReady = true
            origin = originHelper
        }
        
        AxesDrawer(contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var firstValue = true
        var point = CGPoint()
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            point.x = CGFloat(i) / contentScaleFactor
            if let y = dataSource?.y((point.x - origin.x) / scale) {
                if !y.isNormal && !y.isZero {
                    firstValue = true
                    continue
                }
                point.y = origin.y - y * scale
                if firstValue {
                    path.moveToPoint(point)
                    firstValue = false
                } else {
                    path.addLineToPoint(point)
                }
            } else {
                firstValue = true
            }
        }
        path.stroke()
    }
    
    var snapshot:UIView?
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Began:
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
        case .Changed:
            let touch = gesture.locationInView(self)
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.origin.x = snapshot!.frame.origin.x * gesture.scale + (1 - gesture.scale) * touch.x
            snapshot!.frame.origin.y = snapshot!.frame.origin.y * gesture.scale + (1 - gesture.scale) * touch.y
            gesture.scale = 1.0
        case .Ended:
            let changedScale = snapshot!.frame.height / self.frame.height
            scale *= changedScale
            origin.x = origin.x * changedScale + snapshot!.frame.origin.x
            origin.y = origin.y * changedScale + snapshot!.frame.origin.y
            
            snapshot!.removeFromSuperview()
            snapshot = nil
        default: break
        }
    }
    
    func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
        case .Changed:
            let translation = gesture.translationInView(self)
            snapshot!.center.x += translation.x
            snapshot!.center.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        case .Ended:
            origin.x += snapshot!.frame.origin.x
            origin.y += snapshot!.frame.origin.y
            snapshot!.removeFromSuperview()
            snapshot = nil
        default: break
        }
    }
    
    func center(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }
    
}
