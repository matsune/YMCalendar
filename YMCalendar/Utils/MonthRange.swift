//
//  MonthRange.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/20.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation

public struct MonthRange {
    public let start: MonthDate
    public let end: MonthDate
    
    public init(start: MonthDate, end: MonthDate) {
        guard start <= end else {
            fatalError("start and end are not ordered ascendingly")
        }
        self.start = start
        self.end = end
    }
    
    public func contains(_ date: MonthDate) -> Bool {
        let s = start.year * 12 + start.month
        let e = end.year * 12 + end.month
        let d = date.year * 12 + date.month
        return s...e ~= d
    }
}
