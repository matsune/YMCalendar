//
//  MonthDate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/20.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation

public struct MonthDate {
    let year: Int
    let month: Int
    
    public init(year: Int, month: Int) {
        guard year >= 0 && 1...12 ~= month else {
            fatalError("Invalid year or month")
        }
        self.year = year
        self.month = month
    }
    
    public func add(month: Int) -> MonthDate {
        let plusYear = month / 12
        let plusMonth = month % 12
        var y = self.year + plusYear
        var m = self.month + plusMonth
        if m > 12 {
            y += 1
            m = m - 12
        } else if m < 1 {
            y -= 1
            m = 12 + m
        }
        return MonthDate(year: y, month: m)
    }
    
    public func monthDiff(with other: MonthDate) -> Int {
        let yDiff = other.year - year
        let mDiff = other.month - month
        return yDiff * 12 + mDiff
    }
}

extension MonthDate: Equatable, Comparable {
    public static func ==(lhs: MonthDate, rhs: MonthDate) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public static func <(lhs: MonthDate, rhs: MonthDate) -> Bool {
        return lhs.hashValue < rhs.hashValue
    }
}

extension MonthDate: Hashable {
    public var hashValue: Int {
        return year * 12 + month
    }
}
