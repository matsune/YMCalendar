//
//  YMMonthDataSource.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/09.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

protocol YMMonthDataSource: class {
    func YMMonthView(_ view: YMMonthView, numberOfEventsAtDate date: Date) -> Int
    func YMMonthView(_ view: YMMonthView, dateRangeForEventAtIndex index: Int, date: Date) ->  DateRange?
    func YMMonthView(_ view: YMMonthView, cellForEventAtIndex index: Int, date: Date) -> YMEventView
    
    func YMMonthView(_ view: YMMonthView, cellForNewEventAtDate date: Date) -> YMEventView
    func YMMonthView(_ view: YMMonthView, canMoveCellForEventAtIndex index: Int, date: Date) -> Bool
}

extension YMMonthDataSource {
    
    func YMMonthView(_ view: YMMonthView, cellForNewEventAtDate date: Date) -> YMEventView {
        return YMEventView()
    }
    
    func YMMonthView(_ view: YMMonthView, canMoveCellForEventAtIndex index: Int, date: Date) -> Bool {
        return false
    }
}
