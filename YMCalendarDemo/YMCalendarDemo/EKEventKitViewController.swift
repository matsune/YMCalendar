//
//  EKEventKitViewController.swift
//  YMCalendarDemo
//
//  Created by Yuma Matsune on 2017/04/02.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import UIKit
import YMCalendar

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
