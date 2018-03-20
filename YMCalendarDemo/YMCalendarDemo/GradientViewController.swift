//
//  GradientViewController.swift
//  YMCalendarDemo
//
//  Created by Yuma Matsune on 5/6/17.
//  Copyright © 2017 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit
import YMCalendar

final class GradientViewController: UIViewController {

    @IBOutlet weak var calendarWeekBarView: YMCalendarWeekBarView!
    @IBOutlet weak var calendarView: YMCalendarView!
    
    let calendar = Calendar.current
    
    let MyCustomEventViewIdentifier = "MyCustomEventViewIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarWeekBarView.appearance = self
        calendarWeekBarView.calendar = calendar
        calendarWeekBarView.gradientColors = [.sienna, .violetred]
        calendarWeekBarView.gradientStartPoint = CGPoint(x: 0.0, y: 0.5)
        calendarWeekBarView.gradientEndPoint   = CGPoint(x: 1.0, y: 0.5)
        calendarView.dateRange = DateRange(start: makeDate(year: 2017, month: 12, day: 1), end: makeDate(year: 2018, month: 3, day: 1))
        
        calendarView.appearance = self
        calendarView.delegate   = self
        calendarView.dataSource = self
        calendarView.calendar   = calendar
        calendarView.isPagingEnabled = true
        calendarView.scrollDirection = .horizontal
        calendarView.selectAnimation = .fade
        calendarView.eventViewHeight = 22
        calendarView.gradientColors  = [.sienna, .violetred]
        calendarView.gradientStartPoint = CGPoint(x: 0.0, y: 0.5)
        calendarView.gradientEndPoint   = CGPoint(x: 1.0, y: 0.5)
        calendarView.registerClass(MyCustomEventView.self, forEventCellReuseIdentifier: MyCustomEventViewIdentifier)
    }
    
    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar.current.date(from: dateComponents) else {
            assertionFailure("can`t crate Date")
            return Date.distantPast
        }
        return date
    }
}

extension GradientViewController: YMCalendarWeekBarAppearance {
    func weekBarHorizontalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .clear
    }
    
    func weekBarVerticalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .white
    }
    
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textColorAtWeekday weekday: Int) -> UIColor {
        return .white
    }
}

extension GradientViewController: YMCalendarAppearance {
    func horizontalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }
    
    func verticalGridColor(in view: YMCalendarView) -> UIColor {
        return .clear
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        return .white
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedTextColorAtDate date: Date) -> UIColor {
        return .sienna
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedBackgroundColorAtDate date: Date) -> UIColor {
        return .white
    }
}

extension GradientViewController: YMCalendarDelegate {
    func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        navigationItem.title = formatter.string(from: date)
    }
}

extension GradientViewController: YMCalendarDataSource {
    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        if calendar.isDateInToday(date) {
            return 6
        }
        return 0
    }
    
    func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) -> DateRange? {
        if calendar.isDateInToday(date) {
            return DateRange(start: date, end: calendar.endOfDayForDate(date))
        }
        return nil
    }
    
    func calendarView(_ view: YMCalendarView, eventViewForEventAtIndex index: Int, date: Date) -> YMEventView {
        guard let view = view.dequeueReusableCellWithIdentifier(MyCustomEventViewIdentifier, forEventAtIndex: index, date: date) as? MyCustomEventView else {
            fatalError()
        }
        view.label.text = "today"
        view.label.textColor = .white
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        return view
    }
}
