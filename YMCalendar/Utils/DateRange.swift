//
//  DateRange.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/23.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

public struct DateRange {
    public var start: Date
    public var end: Date

    public init(start: Date = Date(), end: Date = Date()) {
        if start.compare(end) == .orderedDescending {
            fatalError("start and end are not ordered ascendingly")
        }
        self.start = start
        self.end = end
    }

    public func contains(date: Date) -> Bool {
        return date.compare(start) != .orderedAscending && date.compare(end) == .orderedAscending
    }

    public func intersectsDateRange(_ range: DateRange) -> Bool {
        return !(range.end.compare(start) != .orderedDescending || end.compare(range.start) != .orderedDescending)
    }

    public func enumerateDaysWithCalendar(_ calendar: Calendar, block: @escaping ((Date) -> Void)) {
        var comp = DateComponents()
        comp.day = 1

        var date = start

        while date < end {
            block(date)
            if let d = calendar.date(byAdding: comp, to: start), let day = comp.day {
                date = d
                comp.day = day + 1
            }
        }
    }
}

extension DateRange: Equatable {
    public static func ==(lhs: DateRange, rhs: DateRange) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}
