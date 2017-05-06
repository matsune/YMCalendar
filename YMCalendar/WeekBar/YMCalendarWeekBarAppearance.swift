//
//  YMCalendarWeekBarAppearance.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/25.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public protocol YMCalendarWeekBarAppearance: class {
    func weekBarHorizontalGridColor(in view: YMCalendarWeekBarView) -> UIColor
    func weekBarHorizontalGridWidth(in view: YMCalendarWeekBarView) -> CGFloat
    func weekBarVerticalGridColor(in view: YMCalendarWeekBarView) -> UIColor
    func weekBarVerticalGridWidth(in view: YMCalendarWeekBarView) -> CGFloat
    
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textAtWeekday weekday: Int) -> String
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textColorAtWeekday weekday: Int) -> UIColor
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, backgroundColorAtWeekday weekday: Int) -> UIColor
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, fontAtWeekday weekday: Int) -> UIFont
}

extension YMCalendarWeekBarAppearance {
    public func weekBarHorizontalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .black
    }
    
    public func weekBarHorizontalGridWidth(in view: YMCalendarWeekBarView) -> CGFloat {
        return 0.3
    }
    
    public func weekBarVerticalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .black
    }
    
    public func weekBarVerticalGridWidth(in view: YMCalendarWeekBarView) -> CGFloat {
        return 0.3
    }
    
    
    public func calendarWeekBarView(_ view: YMCalendarWeekBarView, textAtWeekday weekday: Int) -> String {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[weekday - 1]
    }
    
    public func calendarWeekBarView(_ view: YMCalendarWeekBarView, textColorAtWeekday weekday: Int) -> UIColor {
        return .black
    }
    
    public func calendarWeekBarView(_ view: YMCalendarWeekBarView, backgroundColorAtWeekday weekday: Int) -> UIColor {
        return .clear
    }
    
    public func calendarWeekBarView(_ view: YMCalendarWeekBarView, fontAtWeekday weekday: Int) -> UIFont {
        return .systemFont(ofSize: 12.0)
    }
}
