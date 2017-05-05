//
//  DateExtension.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

extension Calendar {
     func year(_ date: Date) -> Int {
        guard let year = dateComponents([.year], from: date).year else {
            fatalError()
        }
        return year
    }
    
    public func month(_ date: Date) -> Int {
        guard let month = dateComponents([.month], from: date).month else {
            fatalError()
        }
        return month
    }
    
    public func day(_ date: Date) -> Int {
        guard let day = dateComponents([.day], from: date).day else {
            fatalError()
        }
        return day
    }
    
    public func endOfDayForDate(_ date: Date) -> Date {
        var comps = dateComponents([.year, .month, .day], from: self.date(byAdding: .day, value: 1, to: date)!)
        comps.second = -1
        return self.date(from: comps)!
    }
    
    public func startOfMonthForDate(_ date: Date) -> Date {
        var comp = self.dateComponents([.year, .month, .day], from: date)
        comp.day = 1
        return self.date(from: comp)!
    }
    
    public func endOfMonthForDate(_ date: Date) -> Date {
        var comp = self.dateComponents([.year, .month, .day], from: date)
        if let month = comp.month {
            comp.month = month + 1
        }
        comp.day = 0
        return self.date(from: comp)!
    }
    
    public func nextStartOfMonthForDate(_ date: Date) -> Date {
        let firstDay = startOfMonthForDate(date)
        var comp = DateComponents()
        comp.month = 1
        return self.date(byAdding: comp, to: firstDay)!
    }
    
    public func prevStartOfMonthForDate(_ date: Date) -> Date {
        let firstDay = startOfMonthForDate(date)
        var comp = DateComponents()
        comp.month = -1
        return self.date(byAdding: comp, to: firstDay)!
    }
    
    public func numberOfDaysInMonthForDate(_ date: Date) -> Int {
        return range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    public func numberOfWeeksInMonthForDate(_ date: Date) -> Int {
        return range(of: .weekOfMonth, in: .month, for: date)?.count ?? 0
    }
}
