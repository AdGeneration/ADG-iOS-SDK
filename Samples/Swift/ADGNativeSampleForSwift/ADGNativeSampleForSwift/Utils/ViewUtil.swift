//
//  ViewUtil.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/08/10.
//  Copyright © 2016年 Supership. All rights reserved.
//

import Foundation

extension UIView {
    class func createFromNib() -> UIView? {
        let fullClassName = NSStringFromClass(self)
        let range = fullClassName.range(of: ".")
        let className = fullClassName.substring(from: range!.upperBound)
        return UINib(nibName: className, bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func addConstraintsToFitSubView(_ subView: UIView){
        subView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: subView, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: subView, attribute: .trailing, multiplier: 1.0, constant: 0))
    }
}
