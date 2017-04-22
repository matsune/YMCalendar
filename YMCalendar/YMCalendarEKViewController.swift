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
    
    var cachedMonths: [Date : [Date : [EKEvent]]] = [:]
    
    var datesForMonthsToLoad: [Date] = []
    
    var bgQueue = DispatchQueue(label: "YMCalendarEKViewController.bgQueue")
//    var movedEvent: EKEvent?
    
    var calendar: Calendar = .current {
        didSet {
            calendarView.calendar = calendar
        }
    }

    var visibleMonthsRange: DateRange? {
        var range: DateRange? = nil
        if let visibleDaysRange = calendarView.visibleDays {
            let start = calendar.startOfMonthForDate(visibleDaysRange.start)
            let end = calendar.nextStartOfMonthForDate(visibleDaysRange.end)
            range = DateRange(start: start, end: end)
        }
        return range
    }
    
    var visibleMonths: DateRange = DateRange()
    
    let eventKitManager = EventKitManager()
    
    var eventStore: EKEventStore {
        return eventKitManager.eventStore
    }
    
    let YMEventStandardViewIdentifier = "YMEventStandardView"
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate   = self
        calendarView.dataSource = self
        calendarView.appearance = self
        calendarView.registerClass(YMEventStandardView.self, forEventCellReuseIdentifier: YMEventStandardViewIdentifier)
        
        eventKitManager.checkEventStoreAccessForCalendar { [weak self] granted in
            if granted {
                self?.reloadEvents()
            }
        }
    }
    
    func reloadEvents() {
        cachedMonths.removeAll()
        loadEventsIfNeeded()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.recenterIfNeeded()
    }
    
    func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]?) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        if eventKitManager.accessGranted {
            let events = eventStore.events(matching: predicate)
            return events
        }
        return []
    }
    
    func allEventsInDateRange(_ range: DateRange) -> [Date : [EKEvent]] {
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
    
    func bg_loadMonthStartingAtDate(_ date: Date) {
        let end = calendar.nextStartOfMonthForDate(date)
        var range = DateRange(start: date, end: end)
        let dic = allEventsInDateRange(range)
        self.cachedMonths[date] = dic
        
        let rangeEnd = self.calendar.nextStartOfMonthForDate(date)
        range = DateRange(start: date, end: rangeEnd)
        self.calendarView.reloadEventsInRange(range)
    }
    
    func bg_loadOneMonth() {
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
    
    func addMonthToLoadingQueue(monthStart: Date) {
        datesForMonthsToLoad.append(monthStart)
        
        bgQueue.async {
            self.bg_loadOneMonth()
        }
    }
    
    func loadEventsIfNeeded() {
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
    
    func eventsAtDate(_ date: Date) -> [EKEvent] {
        let firstOfMonth = calendar.startOfMonthForDate(date)
        if let days = cachedMonths[firstOfMonth] {
            if let events = days[date] {
                return events
            }
        }
        return []
    }
    
    func eventAtIndex(_ index: Int, date: Date) -> EKEvent {
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

    public func calendarView(_ view: YMCalendarView, cellForEventAtIndex index: Int, date: Date) -> YMEventView? {
        let events = eventsAtDate(date)
        var cell: YMEventStandardView? = nil
        if index <= events.count {
            let event = events[index]
            cell = view.dequeueReusableCellWithIdentifier(YMEventStandardViewIdentifier, forEventAtIndex: index, date: date)
            cell?.layer.cornerRadius = 1.5
            cell?.layer.masksToBounds = true
            cell?.backgroundColor = UIColor(cgColor: event.calendar.cgColor)
            cell?.title = event.title
            cell?.font = .systemFont(ofSize: 10.0)
            cell?.baselineOffset = -1.5
        }
        return cell ?? YMEventStandardView()
    }

    public func calendarView(_ view: YMCalendarView, canMoveCellForEventAtIndex index: Int, date: Date) -> Bool {
//        let events = eventsAtDate(date)
        return false
    }

    public func calendarView(_ view: YMCalendarView, cellForNewEventAtDate date: Date) -> YMEventView? {
        let defaultCalendar = eventStore.defaultCalendarForNewEvents

        let cell = YMEventStandardView()
        cell.title = "New Event"

        return cell
    }
}

// - MARK: YMCalendarAppearance
extension YMCalendarEKViewController: YMCalendarAppearance {
    public func verticalGridlineColor() -> UIColor {
        return .gray
    }

    public func verticalGridlineWidth() -> CGFloat {
        return 1.0
    }

    public func horizontalGridlineColor() -> UIColor {
        return .gray
    }

    public func horizontalGridlineWidth() -> CGFloat {
        return 1.0
    }

    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelFontAtDate date: Date) -> UIFont {
        return .systemFont(ofSize: 10.0)
    }

    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        if calendar.isDate(date, inSameDayAs: Date()) {
            return .orange
        }

        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1:
            return .red
        case 7:
            return .blue
        default:
            return .black
        }
    }

    public func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionBackgroundColorAtDate date: Date) -> UIColor {
        if calendar.isDate(date, inSameDayAs: Date()) {
            return .orange
        }
        return .black
    }
}
