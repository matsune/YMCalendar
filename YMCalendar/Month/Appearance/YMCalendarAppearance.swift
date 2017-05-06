//
//  YMCalendarAppearance.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public protocol YMCalendarAppearance: class {
    func horizontalGridColor(in view: YMCalendarView) -> UIColor
    func horizontalGridWidth(in view: YMCalendarView) -> CGFloat
    func verticalGridColor(in view: YMCalendarView) -> UIColor
    func verticalGridWidth(in view: YMCalendarView) -> CGFloat
    
    func dayLabelAlignment(in view: YMCalendarView) -> YMDayLabelAlignment
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelFontAtDate date: Date) -> UIFont
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelBackgroundColorAtDate date: Date) -> UIColor
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedTextColorAtDate date: Date) -> UIColor
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedBackgroundColorAtDate date: Date) -> UIColor
}

extension YMCalendarAppearance {
    public func horizontalGridColor(in view: YMCalendarView) -> UIColor {
        return .black
    }
    
    public func horizontalGridWidth(in view: YMCalendarView) -> CGFloat {
        return 0.3
    }
    
    public func verticalGridColor(in view: YMCalendarView) -> UIColor {
        return .black
    }
    
    public func verticalGridWidth(in view: YMCalendarView) -> CGFloat {
        return 0.3
    }
    
    public func dayLabelAlignment(in view: YMCalendarView) -> YMDayLabelAlignment {
        return .left
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelFontAtDate date: Date) -> UIFont {
        return .systemFont(ofSize: 10.0)
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        return .black
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelBackgroundColorAtDate date: Date) -> UIColor {
        return .clear
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedTextColorAtDate date: Date) -> UIColor {
        return .white
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedBackgroundColorAtDate date: Date) -> UIColor {
        return .black
    }
}
