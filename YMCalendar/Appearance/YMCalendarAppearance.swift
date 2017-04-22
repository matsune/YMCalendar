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
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelFontAtDate date: Date) -> UIFont
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelBackgroundColorAtDate date: Date) -> UIColor
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionTextColorAtDate date: Date) -> UIColor
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionBackgroundColorAtDate date: Date) -> UIColor
}

extension YMCalendarAppearance {
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelFontAtDate date: Date) -> UIFont {
        return .systemFont(ofSize: 10.0)
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        return .black
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelBackgroundColorAtDate date: Date) -> UIColor {
        return .clear
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionTextColorAtDate date: Date) -> UIColor {
        return .white
    }
    
    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionBackgroundColorAtDate date: Date) -> UIColor {
        return .black
    }
}
