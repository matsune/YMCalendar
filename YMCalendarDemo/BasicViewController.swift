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

final class BasicViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var calendarWeekBarView: YMCalendarWeekBarView!
    @IBOutlet weak var calendarView: YMCalendarView!

    let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()

        /// WeekBarView
        calendarWeekBarView.appearance = self
        calendarWeekBarView.calendar = calendar
        calendarWeekBarView.backgroundColor = .dark

        /// MonthCalendar

        // Delegates
        calendarView.delegate   = self
        calendarView.dataSource = self
        calendarView.appearance = self

        // Month calendar settings
        calendarView.calendar = calendar
        calendarView.backgroundColor = .dark
        calendarView.scrollDirection = .vertical
        calendarView.isPagingEnabled = true

        // Events settings
        calendarView.eventViewHeight  = 14
    }

    @IBAction func allowsMultipleSelectSwitchChanged(_ sender: UISwitch) {
        calendarView.allowsMultipleSelection = sender.isOn
    }

    // firstWeekday picker

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return symbols[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = symbols[row]
        let attrString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return attrString
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        calendar.firstWeekday = row + 1
        calendarWeekBarView.calendar = calendar
        calendarView.calendar = calendar
    }
}

// MARK: - YMCalendarWeekBarDataSource
extension BasicViewController: YMCalendarWeekBarAppearance {
    func horizontalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .white
    }

    func verticalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .white
    }

    // weekday: Int 
    // e.g.) 1: Sunday, 2: Monday,.., 6: Friday, 7: Saturday

    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textAtWeekday weekday: Int) -> String {
        return symbols[weekday - 1]
    }

    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textColorAtWeekday weekday: Int) -> UIColor {
        switch weekday {
        case 1: // Sun
            return .deeppink
        case 7: // Sat
            return .turquoise
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
//        view.selectDayCell(at: date)
    }
}

// MARK: - YMCalendarDataSource
extension BasicViewController: YMCalendarDataSource {
    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        if calendar.isDateInToday(date)
            || calendar.isDate(date, inSameDayAs: calendar.endOfMonthForDate(date))
            || calendar.isDate(date, inSameDayAs: calendar.startOfMonthForDate(date)) {
            return 1
        }
        return 0
    }

    func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) -> DateRange? {
        if calendar.isDateInToday(date)
            || calendar.isDate(date, inSameDayAs: calendar.endOfMonthForDate(date))
            || calendar.isDate(date, inSameDayAs: calendar.startOfMonthForDate(date)) {
            return DateRange(start: date, end: calendar.endOfDayForDate(date))
        }
        return nil
    }

    func calendarView(_ view: YMCalendarView, styleForEventViewAt index: Int, date: Date) -> Style<UIView> {
        return Style<UIView> {
            $0.backgroundColor = .gray
        }
    }
//    func calendarView(_ view: YMCalendarView, eventViewForEventAtIndex index: Int, date: Date) -> UIView {
//        guard let view = view.dequeueReusableCellWithIdentifier("YMEventStandardView", forEventAtIndex: index, date: date) as? YMEventStandardView else {
//            fatalError()
//        }
//        if calendar.isDateInToday(date) {
//            view.title = "today😃"
//        } else if calendar.isDate(date, inSameDayAs: calendar.startOfMonthForDate(date)) {
//            view.title = "startOfMonth"
//        } else if calendar.isDate(date, inSameDayAs: calendar.endOfMonthForDate(date)) {
//            view.title = "endOfMonth"
//        }
//        view.textColor = .white
//        view.backgroundColor = .seagreen
//        return view
//    }
}

// MARK: - YMCalendarAppearance
extension BasicViewController: YMCalendarAppearance {
    // grid lines

    func weekBarHorizontalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }

    func weekBarVerticalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }

    // dayLabel

    func dayLabelAlignment(in view: YMCalendarView) -> YMDayLabelAlignment {
        return .center
    }

    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: // Sun
            return .deeppink
        case 7: // Sat
            return .turquoise
        default:
            return .white
        }
    }

    // Selected dayLabel Color

    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedTextColorAtDate date: Date) -> UIColor {
        return .white
    }

    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedBackgroundColorAtDate date: Date) -> UIColor {
        return .deeppink
    }
}
