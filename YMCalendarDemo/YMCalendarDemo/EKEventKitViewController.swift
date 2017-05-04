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

final class EKEventKitViewController: YMCalendarEKViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.scrollDirection = .vertical
    }
    
    func calendarView(_ view: YMCalendarView, didSelectEventAtIndex index: Int, date: Date) {
        let event = eventAtIndex(index, date: date)
        print(event.title)
    }
}
