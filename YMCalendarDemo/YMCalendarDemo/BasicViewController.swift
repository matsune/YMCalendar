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

    var calendar = Calendar.current
    
    enum Color {
        case dark, deeppink, turquoise, seagreen
        
        var uiColor: UIColor {
            switch self {
            case .dark:
                return UIColor(red: 42/255, green: 52/255, blue: 58/255, alpha: 1.0)
            case .deeppink:
                return UIColor(red: 253/255, green: 63/255, blue: 127/255, alpha: 1.0)
            case .turquoise:
                return UIColor(red: 0, green: 206/255, blue: 209/255, alpha: 1.0)
            case .seagreen:
                return UIColor(red: 67/255, green: 205/255, blue: 128/255, alpha: 1.0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set start weekday to Monday.
        calendar.firstWeekday = 2
        
        /// WeekBarView
        calendarWeekBarView.dataSource = self
        calendarWeekBarView.calendar = calendar
        calendarWeekBarView.horizontalGridColor = .white
        calendarWeekBarView.verticalGridColor = .white
        calendarWeekBarView.backgroundColor = Color.dark.uiColor

        
        /// MonthCalendar
        
        // Delegates
        calendarView.delegate   = self
        calendarView.dataSource = self
        calendarView.appearance = self
        
        // Month calendar settings
        calendarView.calendar = calendar
        calendarView.backgroundColor = Color.dark.uiColor
        calendarView.scrollDirection = .horizontal
        calendarView.isPagingEnabled = true
        calendarView.horizontalGridColor  = .white
        calendarView.verticalGridColor    = .white
//        calendarView.selectAnimation   = .fade
        
        // Events settings
        calendarView.eventViewHeight  = 14
        calendarView.registerClass(YMEventStandardView.self, forEventCellReuseIdentifier: "YMEventStandardView")
    }
    
    
    @IBAction func allowsMultipleSelectSwitchChanged(_ sender: UISwitch) {
        calendarView.allowsMultipleSelection = sender.isOn
    }
}

// MARK: - YMCalendarWeekBarDataSource
extension BasicViewController: YMCalendarWeekBarDataSource {
    
    // weekday: Int 
    // e.g.) 1: Sunday, 2: Monday,.., 6: Friday, 7: Saturday
    
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textAtWeekday weekday: Int) -> String {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[weekday - 1]
    }
    
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textColorAtWeekday weekday: Int) -> UIColor {
        switch weekday {
        case 1: // Sun
            return Color.deeppink.uiColor
        case 7: // Sat
            return Color.turquoise.uiColor
        default:
            return .white
        }
    }
}

// MARK: - YMCalendarDelegate
extension BasicViewController: YMCalendarDelegate {
    func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        navigationItem.title = formatter.string(from: date)
    }
    
    func calendarView(_ view: YMCalendarView, didMoveMonthOfStartDate date: Date) {
//        // If you want to auto select when displaying month has changed
//        view.deselectItem()
//        view.selectItem(at: date)
    }
}


// MARK: - YMCalendarDataSource
extension BasicViewController: YMCalendarDataSource {
    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        if calendarView.calendar.isDateInToday(date) {
            return 5
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
        view.textColor = .black
        view.backgroundColor = Color.seagreen.uiColor
        return view
    }
}

// MARK: - YMCalendarAppearance
extension BasicViewController: YMCalendarAppearance {
    
    // dayLabel
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: // Sun
            return Color.deeppink.uiColor
        case 7: // Sat
            return Color.turquoise.uiColor
        default:
            return .white
        }
    }
    
    // Selected dayLabel Color
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionTextColorAtDate date: Date) -> UIColor {
        return .white
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectionBackgroundColorAtDate date: Date) -> UIColor {
        return Color.deeppink.uiColor
    }
}
