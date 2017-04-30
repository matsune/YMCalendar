//
//  BasicViewController.swift
//  YMCalendarDemo
//
//  Created by Yuma Matsune on 2017/04/23.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit
import YMCalendar

final class BasicViewController: UIViewController {

    @IBOutlet weak var calendarWeekBarView: YMCalendarWeekBarView!
    @IBOutlet weak var calendarView: YMCalendarView!

    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.scrollDirection = .horizontal
        calendarView.isPagingEnabled = true
        calendarView.calendar = calendar
        calendarView.registerClass(YMEventStandardView.self, forEventCellReuseIdentifier: "YMEventStandardView")
    }
}

extension BasicViewController: YMCalendarDelegate {
    func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        navigationItem.title = formatter.string(from: date)
    }
}

extension BasicViewController: YMCalendarDataSource {

    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        if calendarView.calendar.isDateInToday(date) {
            return 1
        }
        return 0
    }
    
    func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) ->  DateRange? {
        return DateRange(start: calendar.startOfDay(for: date), end: calendar.endOfDayForDate(date))
    }
    
    func calendarView(_ view: YMCalendarView, eventViewForEventAtIndex index: Int, date: Date) -> YMEventView {
        guard let view = view.dequeueReusableCellWithIdentifier("YMEventStandardView", forEventAtIndex: index, date: date) as? YMEventStandardView else {
            fatalError()
        }
        view.title = "today!"
        view.textColor = .white
        view.backgroundColor = .blue
        return view
    }
}
