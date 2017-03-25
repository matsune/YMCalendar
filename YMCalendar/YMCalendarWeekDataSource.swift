//
//  YMCalendarWeekDataSource.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/25.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public protocol YMCalendarWeekDataSource: class {
    func calendarWeekView(_ view: YMCalendarWeekView, textAtWeekday weekday: Int) -> String
    func calendarWeekView(_ view: YMCalendarWeekView, textColorAtWeekday weekday: Int) -> UIColor
    func calendarWeekView(_ view: YMCalendarWeekView, backgroundColorAtWeekday weekday: Int) -> UIColor
    func calendarWeekView(_ view: YMCalendarWeekView, fontAtWeekday weekday: Int) -> UIFont
}

extension YMCalendarWeekDataSource {
    public func calendarWeekView(_ view: YMCalendarWeekView, textAtWeekday weekday: Int) -> String {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[weekday - 1]
    }
    
    public func calendarWeekView(_ view: YMCalendarWeekView, textColorAtWeekday weekday: Int) -> UIColor {
        return .black
    }
    
    public func calendarWeekView(_ view: YMCalendarWeekView, backgroundColorAtWeekday weekday: Int) -> UIColor {
        return .clear
    }
    
    public func calendarWeekView(_ view: YMCalendarWeekView, fontAtWeekday weekday: Int) -> UIFont {
        return .systemFont(ofSize: 12.0)
    }
}
