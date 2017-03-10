//
//  DateRange.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/23.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

struct DateRange {
    let start: Date
    let end: Date
    
    init(start: Date = Date(), end: Date = Date()){
        self.start = start
        self.end = end
    }
    
    func contains(date : Date) -> Bool {
        checkIfValid()
        
        return date.compare(start) != .orderedAscending && date.compare(end) == .orderedAscending
    }
    
//    func intersectDateRange(_ range: DateRange) {
//        checkIfValid()
//        
//        if range.end.compare(start) != .orderedDescending || end.compare(range.start) != .orderedDescending {
//            end = start
//            return
//        }
//        
//        if start.compare(range.start) == .orderedAscending {
//            start = range.start
//        }
//        if range.end.compare(end) == .orderedAscending {
//            end = range.end
//        }
//    }
//    
    func intersectsDateRange(_ range: DateRange) -> Bool {
        return !(range.end.compare(start) != .orderedDescending || end.compare(range.start) != .orderedDescending)
    }
    
    func checkIfValid() {
        if start.compare(end) != .orderedDescending {
            assertionFailure("End date earlier than start date in DateRange object!")
        }
    }
}

func ==(lhs: DateRange, rhs: DateRange) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

func !=(lhs: DateRange, rhs: DateRange) -> Bool {
    return !(lhs == rhs)
}
