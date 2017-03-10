//
//  YMMonthDelegate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/23.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

@objc
protocol YMMonthDelegate: class {
    @objc optional func monthView(_ view: YMMonthView, didShowDate date: Date)
//    @objc optional func YMMonthView(_ view: YMMonthView, didSelectEvent event: EKEvent)
    
//    @objc optional func YMMonthView(_ view: YMMonthView, attributedStringForDayHeaderAtDate date: Date) -> NSAttributedString
    @objc optional func monthViewDidScroll(_ view: YMMonthView)
    @objc optional func monthView(_ view: YMMonthView, didSelectDayCellAtDate date: Date)
    @objc optional func monthView(_ view: YMMonthView, didShowCell cell: UIView, forNewEventAtDate date: Date)
//    @objc optional func YMMonthView(_ view: YMMonthView, willStartMovingEventAtIndex index: Int, date: Date)
//    @objc optional func YMMonthView(_ view: YMMonthView, didMoveEventAtIndex index: Int, date dateOld: Date, toDate dayNew: Date)
    @objc optional func monthView(_ view: YMMonthView, didDeselectEventAtIndex index: Int, date: Date)
}

extension YMMonthDelegate {
//    func YMMonthViewDidScroll(_ view: YMMonthView) {
////        let visibleMonths = view.visible
//    }
}
