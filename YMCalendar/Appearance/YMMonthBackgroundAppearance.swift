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
    func verticalGridlineColor() -> UIColor
    func verticalGridlineWidth() -> CGFloat
    func horizontalGridlineColor() -> UIColor
    func horizontalGridlineWidth() -> CGFloat
}

extension YMMonthBackgroundAppearance {
    public func verticalGridlineColor() -> UIColor {
        return .black
    }
    
    public func verticalGridlineWidth() -> CGFloat {
        return 0.3
    }
    
    public func horizontalGridlineColor() -> UIColor {
        return .black
    }
    
    public func horizontalGridlineWidth() -> CGFloat {
        return 0.3
    }
}
