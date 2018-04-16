//
//  UIView+SGPagingView.swift
//  SGPagingViewDemo
//
//  Created by Apple on 2018/4/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

extension UIView {
    
    func setSG_x(SG_x: CGFloat) {
        var frame = self.frame
        frame.origin.x = SG_x
        self.frame = frame
    }
    
    func SG_x() -> CGFloat {
        return self.frame.origin.x
    }
    
    func setSG_y(SG_y: CGFloat) {
        var frame = self.frame
        frame.origin.y = SG_y
        self.frame = frame
    }
    
    func SG_y() -> CGFloat {
        return self.frame.origin.y
    }
    
    func setSG_width(SG_width: CGFloat) {
        var frame = self.frame
        frame.size.width = SG_width
        self.frame = frame
    }
    
    func SG_width() -> CGFloat {
        return self.frame.size.width
    }
    
    func setSG_height(SG_height: CGFloat) {
        var frame = self.frame
        frame.size.height = SG_height
        self.frame = frame
    }
    
    func SG_height() -> CGFloat {
        return self.frame.size.height
    }
    
    func setSG_centerX(SG_centerX: CGFloat) {
        var center = self.center
        center.x = SG_centerX
        self.center = center
    }
    
    func SG_centerX() -> CGFloat {
        return self.center.x
    }
    
    func setSG_centerY(SG_centerY: CGFloat) {
        var center = self.center
        center.y = SG_centerY
        self.center = center
    }
    
    func SG_centerY() -> CGFloat {
        return self.center.y
    }
    
    func setSG_origin(SG_origin: CGPoint) {
        var frame = self.frame
        frame.origin = SG_origin
        self.frame = frame
    }
    
    func SG_origin() -> CGPoint {
        return self.frame.origin
    }
    
    func setSG_size(SG_size: CGSize) {
        var frame = self.frame
        frame.size = SG_size
        self.frame = frame
    }
    
    func SG_size() -> CGSize {
        return self.frame.size
    }
   
}

protocol NibLoadable {}

extension NibLoadable {
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}

