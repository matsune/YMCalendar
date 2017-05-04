//
//  YMCalendarDelegate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/23.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit
import EventKit

@objc
public protocol YMCalendarDelegate: class {
    @objc optional func calendarViewDidScroll(_ view: YMCalendarView)
    @objc optional func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date)
    @objc optional func calendarView(_ view: YMCalendarView, didMoveMonthOfStartDate date: Date)
    @objc optional func calendarView(_ view: YMCalendarView, shouldSelectEventAtIndex index: Int, date: Date) -> Bool
    @objc optional func calendarView(_ view: YMCalendarView, didSelectEventAtIndex index: Int, date: Date)
    @objc optional func calendarView(_ view: YMCalendarView, shouldDeselectEventAtIndex index: Int, date: Date) -> Bool
    @objc optional func calendarView(_ view: YMCalendarView, didDeselectEventAtIndex index: Int, date: Date)
}
