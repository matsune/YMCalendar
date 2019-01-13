//
//  YMDecelerationRate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/05.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public enum YMDecelerationRate {
    case normal, fast
    
    var value: CGFloat {
        switch self {
        case .normal:
            return UIScrollView.DecelerationRate.normal.rawValue
        case .fast:
            return UIScrollView.DecelerationRate.fast.rawValue
        }
    }
}
