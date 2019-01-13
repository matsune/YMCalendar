//
//  YMEventView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

open class YMEventView: UIView, ReusableObject {
    
    public var reuseIdentifier: String = ""
    
    public var selected: Bool = false
    
    public var visibleHeight: CGFloat = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
    }
    
    public func prepareForReuse() {
        selected = false
    }
}
