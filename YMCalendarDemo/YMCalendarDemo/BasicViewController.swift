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

    @IBOutlet weak var calendarView: YMCalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
    }
}

extension BasicViewController: YMCalendarDelegate {
    func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        navigationItem.title = formatter.string(from: date)
    }
}
