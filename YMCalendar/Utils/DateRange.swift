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
        self.start = start
        self.end = end
    }
    
    public func components(_ unitFlags: Set<Calendar.Component>, forCalendar calendar: Calendar) -> DateComponents {
        checkIfValid()
        return calendar.dateComponents(unitFlags, from: start, to: end)
    }
    
    public func contains(date : Date?) -> Bool {
        checkIfValid()
        
        guard let date = date else {
            return false
        }
        return date.compare(start) != .orderedAscending && date.compare(end) == .orderedAscending
    }
    
    public mutating func intersectDateRange(_ range: DateRange) {
        checkIfValid()
        
        if range.end.compare(start) != .orderedDescending || end.compare(range.start) != .orderedDescending {
            end = start
            return
        }
        
        if start.compare(range.start) == .orderedAscending {
            start = range.start
        }
        if range.end.compare(end) == .orderedAscending {
            end = range.end
        }
    }
    
    public func intersectsDateRange(_ range: DateRange) -> Bool {
        return !(range.end.compare(start) != .orderedDescending || end.compare(range.start) != .orderedDescending)
    }
    
    public func includesDateRange(_ range: DateRange) -> Bool {
        if range.start.compare(start) == .orderedAscending || end.compare(range.end) == .orderedAscending {
            return false
        }
        return true
    }

    func checkIfValid() {
        if start.compare(end) != .orderedAscending {
            assertionFailure("end date should be later than start date in DateRange object!")
        }
    }
    
    public func enumerateDaysWithCalendar(_ calendar: Calendar, usingBlock block: (Date, inout Bool) -> ()) {
        var comp = DateComponents()
        comp.day = 1
        
        var date = start
        var stop = false
        
        while !stop && date.compare(end) == .orderedAscending {
            block(date, &stop)
            if let d = calendar.date(byAdding: comp, to: start), let day = comp.day {
                date = d
                comp.day = day + 1
            }
        }
    }
}

public func ==(lhs: DateRange, rhs: DateRange) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

public func !=(lhs: DateRange, rhs: DateRange) -> Bool {
    return !(lhs == rhs)
}
