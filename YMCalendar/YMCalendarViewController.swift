//
//  YMCalendarViewController.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/04/02.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import EventKit

open class YMCalendarViewController: UIViewController {
    
    public var calendarView: YMCalendarView {
        get {
            return view as! YMCalendarView
        }
        set {
            view = newValue
        }
    }
    
    open override func loadView() {
        calendarView = YMCalendarView()
    }
}
