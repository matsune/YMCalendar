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
    
    
    var events: [Date : [String]] = [:]
    
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
        
        // make 5 events on today and 1 event on 5 days from today
        let today = calendar.startOfDay(for: Date())
        events[today] = ["You can", "scroll", "down", "↓", "😃"]
        events[calendar.date(byAdding: .day, value: 5, to: today)!] = ["3 days event"]
    }
    
    
    @IBAction func allowsMultipleSelectSwitchChanged(_ sender: UISwitch) {
        calendarView.allowsMultipleSelection = sender.isOn
    }
    
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
        let attrString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attrString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        calendar.firstWeekday = row + 1
        calendarWeekBarView.calendar = calendar
        calendarView.calendar = calendar
    }
}

// MARK: - YMCalendarWeekBarDataSource
extension BasicViewController: YMCalendarWeekBarDataSource {
    
    // weekday: Int 
    // e.g.) 1: Sunday, 2: Monday,.., 6: Friday, 7: Saturday
    
    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textAtWeekday weekday: Int) -> String {
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
//        view.selectDayCell(at: date)
    }
}


// MARK: - YMCalendarDataSource
extension BasicViewController: YMCalendarDataSource {
    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        return events[date]?.count ?? 0
    }
    
    func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) ->  DateRange? {
        if let events = events[date] {
            if events.count > 1 { // today
                return DateRange(start: calendar.startOfDay(for: date), end: calendar.endOfDayForDate(date))
            } else { // 5 days from today
                if let end = calendar.date(byAdding: .day, value: 2, to: date) { // this event is 3 days over
                    return DateRange(start: calendar.startOfDay(for: date), end: calendar.endOfDayForDate(end))
                }
            }
        }
        return nil
    }
    
    func calendarView(_ view: YMCalendarView, eventViewForEventAtIndex index: Int, date: Date) -> YMEventView {
        guard let events = events[date],
            let view = view.dequeueReusableCellWithIdentifier("YMEventStandardView", forEventAtIndex: index, date: date) as? YMEventStandardView else {
            fatalError()
        }
        view.title = events[index]
        view.textColor = .white
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
