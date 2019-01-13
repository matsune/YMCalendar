//
//  Calendar.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/21.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation

extension Calendar {
    func day(_ date: Date) -> Int {
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
        var comp = dateComponents([.year, .month, .day], from: date)
        comp.day = 1
        return self.date(from: comp)!
    }

   public func endOfMonthForDate(_ date: Date) -> Date {
        var comp = dateComponents([.year, .month, .day], from: date)
        if let month = comp.month {
            comp.month = month + 1
        }
        comp.day = 0
        return self.date(from: comp)!
    }

    func nextStartOfMonthForDate(_ date: Date) -> Date {
        let firstDay = startOfMonthForDate(date)
        var comp = DateComponents()
        comp.month = 1
        return self.date(byAdding: comp, to: firstDay)!
    }

    func numberOfDaysInMonth(date: Date) -> Int {
        return range(of: .day, in: .month, for: date)?.count ?? 0
    }

    func numberOfWeeksInMonth(date: Date) -> Int {
        return range(of: .weekOfMonth, in: .month, for: date)?.count ?? 0
    }

    func date(from monthDate: MonthDate) -> Date {
        let dateComponents = DateComponents(year: monthDate.year, month: monthDate.month, day: 1)
        guard let date = date(from: dateComponents) else {
            fatalError()
        }
        return date
    }

    func monthDate(from date: Date) -> MonthDate {
        let comp = dateComponents([.year, .month], from: date)
        guard let year = comp.year, let month = comp.month else {
            fatalError()
        }
        return MonthDate(year: year, month: month)
    }
}
