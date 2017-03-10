//
//  YMMonthBackgroundAppearance.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public protocol YMMonthBackgroundAppearance: class {
    func isDrawVerticalLines() -> Bool
    func isDrawHorizontalLines() -> Bool
    
    func gridColor() -> UIColor
    func gridLineWidth() -> CGFloat
}

extension YMMonthBackgroundAppearance {
    public func isDrawHorizontalLines() -> Bool {
        return true
    }
    public func isDrawVerticalLines() -> Bool {
        return true
    }
    public func gridColor() -> UIColor {
        return .black
    }
    public func gridLineWidth() -> CGFloat {
        return 0.5
    }
}
