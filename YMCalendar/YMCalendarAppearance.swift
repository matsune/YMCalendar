//
//  YMCalendarAppearance.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public protocol YMCalendarAppearance: YMMonthBackgroundAppearance {
    func dayLabelFontAtDate(_ date: Date) -> UIFont
    func dayLabelTextColorAtDate(_ date: Date) -> UIColor
}

extension YMCalendarAppearance {
    public func dayLabelFontAtDate(_ date: Date) -> UIFont {
        return .systemFont(ofSize: 10.0)
    }
    
    public func dayLabelTextColorAtDate(_ date: Date) -> UIColor {
        return .black
    }
}
