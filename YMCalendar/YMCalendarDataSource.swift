//
//  YMCalendarDataSource.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/09.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

public protocol YMCalendarDataSource: class {
    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int
    func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) ->  DateRange?
    func calendarView(_ view: YMCalendarView, cellForEventAtIndex index: Int, date: Date) -> YMEventView?
    
    func calendarView(_ view: YMCalendarView, cellForNewEventAtDate date: Date) -> YMEventView?
    func calendarView(_ view: YMCalendarView, canMoveCellForEventAtIndex index: Int, date: Date) -> Bool
}

extension YMCalendarDataSource {
    public func calendarView(_ view: YMCalendarView, canMoveCellForEventAtIndex index: Int, date: Date) -> Bool {
        return false
    }
}
