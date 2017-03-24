//
//  YMEventView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public class YMEventView: UIView, ReusableObject {
    
    public var reuseIdentifier: String = ""
    
    var selected: Bool = false
    
    var visibleHeight: CGFloat = 0
    
    override init(frame: CGRect) {
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
