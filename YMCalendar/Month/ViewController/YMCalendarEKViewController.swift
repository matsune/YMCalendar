//
//  YMCalendarEKViewController.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/04/02.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit
import EventKit

open class YMCalendarEKViewController: YMCalendarViewController {
    
    fileprivate var cachedMonths: [Date : [Date : [EKEvent]]] = [:]
    
    fileprivate var datesForMonthsToLoad: [Date] = []
    
    fileprivate var bgQueue = DispatchQueue(label: "YMCalendarEKViewController.bgQueue")
    
    public var calendar: Calendar = .current {
        didSet {
            calendarView.calendar = calendar
        }
    }

    public var visibleMonthsRange: DateRange? {
        var range: DateRange? = nil
        if let visibleDaysRange = calendarView.visibleDays {
            let start = calendar.startOfMonthForDate(visibleDaysRange.start)
            let end = calendar.nextStartOfMonthForDate(visibleDaysRange.end)
            range = DateRange(start: start, end: end)
        }
        return range
    }
    
    public var visibleMonths: DateRange = DateRange()
    
    public let eventKitManager = EventKitManager()
    
    fileprivate var eventStore: EKEventStore {
        return eventKitManager.eventStore
    }
    
    fileprivate let YMEventStandardViewIdentifier = "YMEventStandardView"
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate   = self
        calendarView.dataSource = self
        calendarView.registerClass(YMEventStandardView.self, forEventCellReuseIdentifier: YMEventStandardViewIdentifier)
        
        eventKitManager.checkEventStoreAccessForCalendar { [weak self] granted in
            if granted {
                self?.reloadEvents()
            }
        }
    }
    
    public func reloadEvents() {
        cachedMonths.removeAll()
        loadEventsIfNeeded()
    }
    
    fileprivate func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]?) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        if eventKitManager.isGranted {
            let events = eventStore.events(matching: predicate)
            return events
        }
        return []
    }
    
    fileprivate func allEventsInDateRange(_ range: DateRange) -> [Date : [EKEvent]] {
        let events = fetchEvents(from: range.start, to: range.end, calendars: nil)
        
        var eventsPerDay: [Date : [EKEvent]] = [:]
        for event in events {
            let start = calendar.startOfDay(for: event.startDate)
            let eventRange = DateRange(start: start, end: event.endDate)
            
            eventRange.enumerateDaysWithCalendar(calendar, usingBlock: { date, stop in
                if eventsPerDay[date] == nil {
                    eventsPerDay[date] = []
                }
                eventsPerDay[date]?.append(event)
            })
        }
        return eventsPerDay
    }
    
    fileprivate func bg_loadMonthStartingAtDate(_ date: Date) {
        let end = calendar.nextStartOfMonthForDate(date)
        var range = DateRange(start: date, end: end)
        let dic = allEventsInDateRange(range)
        self.cachedMonths[date] = dic
        
        let rangeEnd = self.calendar.nextStartOfMonthForDate(date)
        range = DateRange(start: date, end: rangeEnd)
        self.calendarView.reloadEventsInRange(range)
    }
    
    fileprivate func bg_loadOneMonth() {
        var date: Date? = nil
        if let d = datesForMonthsToLoad.first {
            date = d
            datesForMonthsToLoad.removeFirst()
        }
        if let visibleDays = calendarView.visibleDays,
            !visibleDays.intersectsDateRange(visibleMonths) {
            date = nil
        }
        if let date = date {
            bg_loadMonthStartingAtDate(date)
        }
    }
    
    fileprivate func addMonthToLoadingQueue(monthStart: Date) {
        datesForMonthsToLoad.append(monthStart)
        
        bgQueue.async {
            self.bg_loadOneMonth()
        }
    }
    
    public func loadEventsIfNeeded() {
        datesForMonthsToLoad.removeAll()
        
        guard let visibleMonthsRange = visibleMonthsRange,
            let months = visibleMonthsRange.components([.month], forCalendar: calendar).month else {
                return
        }
        for i in 0..<months {
            var dc = DateComponents()
            dc.month = i
            if let date = calendar.date(byAdding: dc, to: visibleMonthsRange.start) {
                if cachedMonths[date] == nil {
                    addMonthToLoadingQueue(monthStart: date)
                }
            }
        }
    }
    
    public func eventsAtDate(_ date: Date) -> [EKEvent] {
        let firstOfMonth = calendar.startOfMonthForDate(date)
        if let days = cachedMonths[firstOfMonth] {
            if let events = days[date] {
                return events
            }
        }
        return []
    }
    
    public func eventAtIndex(_ index: Int, date: Date) -> EKEvent {
        let events = eventsAtDate(date)
        return events[index]
    }

}


// - MARK: YMCalendarDelegate
extension YMCalendarEKViewController: YMCalendarDelegate {
    public func calendarViewDidScroll(_ view: YMCalendarView) {
        if let visibleMonthsRange = visibleMonthsRange, visibleMonths != visibleMonthsRange {
            self.visibleMonths = visibleMonthsRange
            self.loadEventsIfNeeded()
        }
    }
}

// - MARK: YMCalendarDataSource
extension YMCalendarEKViewController: YMCalendarDataSource {
    public func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        return eventsAtDate(date).count
    }

    public func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) -> DateRange? {
        let events = eventsAtDate(date)
        var range: DateRange? = nil
        if index <= events.count {
            let event = events[index]
            range = DateRange(start: event.startDate, end: event.endDate)
        }
        return range
    }

    open func calendarView(_ view: YMCalendarView, eventViewForEventAtIndex index: Int, date: Date) -> YMEventView {
        let events = eventsAtDate(date)
        precondition(index <= events.count)
        
        let event = events[index]
        guard let cell = view.dequeueReusableCellWithIdentifier(YMEventStandardViewIdentifier, forEventAtIndex: index, date: date) as? YMEventStandardView else {
            fatalError()
        }
        cell.backgroundColor = UIColor(cgColor: event.calendar.cgColor)
        cell.title = event.title
        return cell
    }
}
