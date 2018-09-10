//
//  EKEventKitViewController.swift
//  YMCalendarDemo
//
//  Created by Yuma Matsune on 2017/04/02.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import UIKit
import YMCalendar

/**
    YMCalendarEKViewController is userful UIViewController superclass.
    It has YMCalendarView as `calendarView` as default. If you want to access
    and get events from calendar app instantly, only to implement this superclass.
 */

final class EKEventKitViewController: YMCalendarEKViewController, YMCalendarAppearance {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.appearance = self
        calendarView.scrollDirection = .vertical
        calendarView.gradientColors  = [.lightblue, .oceanblue]
    }
    
    func calendarView(_ view: YMCalendarView, didSelectEventAtIndex index: Int, date: Date) {
        let event = eventAtIndex(index, date: date)
        print(event.title)
    }
    
    func horizontalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }
    
    func verticalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        return .white
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedTextColorAtDate date: Date) -> UIColor {
        return .oceanblue
    }
    
    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedBackgroundColorAtDate date: Date) -> UIColor {
        return .white
    }
}
