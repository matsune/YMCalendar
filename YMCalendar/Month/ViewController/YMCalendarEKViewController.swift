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
    typealias EventsDict = [Date: [EKEvent]]
    private var cachedEvents: [MonthDate: EventsDict] = [:]
    private var queueToLoad: [MonthDate] = []
    private var bgQueue = DispatchQueue(label: "YMCalendarEKViewController.bgQueue")

    private var visibleMonths: [MonthDate] = []

    public var calendar: Calendar = .current {
        didSet {
            calendarView.calendar = calendar
        }
    }

    public let eventKitManager = EventKitManager()

    private var eventStore: EKEventStore {
        return eventKitManager.eventStore
    }

    private let YMEventStandardViewIdentifier = "YMEventStandardView"

    override open func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate   = self
        calendarView.dataSource = self

        eventKitManager.checkEventStoreAccessForCalendar { [weak self] granted in
            if granted {
                self?.reloadEvents()
            }
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadEventsIfNeeded()
    }

    public func reloadEvents() {
        cachedEvents.removeAll()
        queueToLoad.removeAll()
        visibleMonths.removeAll()

        DispatchQueue.main.async {
            self.loadEventsIfNeeded()
        }
    }

    private func fetchEvents(in month: MonthDate, calendars: [EKCalendar]?) -> [EKEvent] {
        let start = calendar.date(from: month)
        let end = calendar.nextStartOfMonthForDate(calendar.date(from: month))
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        if eventKitManager.isGranted {
            let events = eventStore.events(matching: predicate)
            return events
        }
        return []
    }

    private func loadMonth(_ month: MonthDate) {
        let events = fetchEvents(in: month, calendars: nil)

        var eventsDict: EventsDict = [:]
        for event in events {
            let start = calendar.startOfDay(for: event.startDate)
            let eventRange = DateRange(start: start, end: event.endDate)
            eventRange.enumerateDaysWithCalendar(calendar) {
                if eventsDict[$0] == nil {
                    eventsDict[$0] = []
                }
                eventsDict[$0]?.append(event)
            }
        }

        cachedEvents[month] = eventsDict

        DispatchQueue.main.async {
            self.calendarView.reloadEvents(in: month)
        }
    }

    private func addMonthsToLoad(months: [MonthDate]) {
        let loadMonths = months.filter { month -> Bool in
            !cachedEvents.contains(where: { $0.key == month })
        }
        queueToLoad.append(contentsOf: loadMonths)

        bgQueue.async { [weak self] in
            loadMonths.forEach {
                self?.loadMonth($0)
                if let idx = self?.queueToLoad.index(of: $0) {
                    self?.queueToLoad.remove(at: idx)
                }
            }
        }
    }

    public func eventsAtDate(_ date: Date) -> [EKEvent] {
        if let monthEvents = cachedEvents[calendar.monthDate(from: date)] {
            if let events = monthEvents[date] {
                return events
            }
        }
        return []
    }

    public func eventAtIndex(_ index: Int, date: Date) -> EKEvent {
        return eventsAtDate(date)[index]
    }

    public func loadEventsIfNeeded() {
        if visibleMonths != calendarView.visibleMonths {
            self.visibleMonths = calendarView.visibleMonths
            addMonthsToLoad(months: visibleMonths)
        }
    }
}

// - MARK: YMCalendarDelegate
extension YMCalendarEKViewController: YMCalendarDelegate {
    public func calendarViewDidScroll(_ view: YMCalendarView) {
        loadEventsIfNeeded()
    }
}

// - MARK: YMCalendarDataSource
extension YMCalendarEKViewController: YMCalendarDataSource {
    public func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        return eventsAtDate(date).count
    }

    public func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) -> DateRange? {
        let events = eventsAtDate(date)
        var range: DateRange?
        if index <= events.count {
            let event = events[index]
            range = DateRange(start: event.startDate, end: event.endDate)
        }
        return range
    }

    public func calendarView(_ view: YMCalendarView, styleForEventViewAt index: Int, date: Date) -> Style<UIView> {
        return Style<UIView> {
            $0.backgroundColor = .blue
        }
    }
}
