//
//  YMCalendarViewAnimator.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/28.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

public enum YMCalendarSelectionAnimation {
    case none, bounce, fade
}

protocol YMCalendarViewAnimator {
    var selectionAnimation: YMCalendarSelectionAnimation { get set }
    var deselectionAnimation: YMCalendarSelectionAnimation { get set }
    
    func animateSelectionDayCell(_ cell: YMMonthDayCollectionCell)
    func animateDeselectionDayCell(_ cell: YMMonthDayCollectionCell)
}

extension YMCalendarViewAnimator {
    func animateSelectionDayCell(_ cell: YMMonthDayCollectionCell) {
        cell.animateSelection(withAnimation: selectionAnimation)
    }
    
    func animateDeselectionDayCell(_ cell: YMMonthDayCollectionCell) {
        cell.animateDeselection(withAnimation: deselectionAnimation)
    }
}
