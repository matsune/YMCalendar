//
//  YMCalendarDelegate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/23.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol YMCalendarDelegate: class {
    @objc optional func calendarView(_ view: YMCalendarView, didShowDate date: Date)
//    @objc optional func YMCalendarView(_ view: YMCalendarView, didSelectEvent event: EKEvent)
    
//    @objc optional func YMCalendarView(_ view: YMCalendarView, attributedStringForDayHeaderAtDate date: Date) -> NSAttributedString
    @objc optional func calendarViewDidScroll(_ view: YMCalendarView)
    @objc optional func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date)
    @objc optional func calendarView(_ view: YMCalendarView, didShowCell cell: UIView, forNewEventAtDate date: Date)
//    @objc optional func YMCalendarView(_ view: YMCalendarView, willStartMovingEventAtIndex index: Int, date: Date)
//    @objc optional func YMCalendarView(_ view: YMCalendarView, didMoveEventAtIndex index: Int, date dateOld: Date, toDate dayNew: Date)
    @objc optional func monthView(_ view: YMCalendarView, didDeselectEventAtIndex index: Int, date: Date)
}

extension YMCalendarDelegate {
//    func YMCalendarViewDidScroll(_ view: YMCalendarView) {
////        let visibleMonths = view.visible
//    }
}
