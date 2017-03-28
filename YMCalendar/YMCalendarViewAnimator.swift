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
    
    func animateSelectionDayCell(_ cell: YMMonthDayCollectionCell)
    func animateDeselectionDayCell(_ cell: YMMonthDayCollectionCell)
}

extension YMCalendarViewAnimator {
    func animateSelectionDayCell(_ cell: YMMonthDayCollectionCell) {
        switch selectionAnimation {
        case .none:
            selectAnimationWithNone(cell)
        case .bounce:
            selectAnimationWithBounce(cell)
        case .fade:
            selectAnimationWithFade(cell)
        }
    }
    
    func animateDeselectionDayCell(_ cell: YMMonthDayCollectionCell) {
        switch selectionAnimation {
        case .none:
            deselectAnimationWithNone(cell)
        case .bounce:
            deselectAnimationWithBounce(cell)
        case .fade:
            deselectAnimationWithFade(cell)
        }
    }
    
    // MARK: None
    func selectAnimationWithNone(_ cell: YMMonthDayCollectionCell) {
        cell.dayLabel.textColor = cell.dayLabelSelectionColor
        cell.dayLabel.backgroundColor = cell.dayLabelSelectionBackgroundColor
    }
    
    func deselectAnimationWithNone(_ cell: YMMonthDayCollectionCell) {
        cell.dayLabel.textColor = cell.dayLabelColor
        cell.dayLabel.backgroundColor = cell.dayLabelBackgroundColor
    }
    
    // MARK: Bounce
    func selectAnimationWithBounce(_ cell: YMMonthDayCollectionCell) {
        
    }
    
    func deselectAnimationWithBounce(_ cell: YMMonthDayCollectionCell) {
        
    }
    
    // MARK: Fade
    func selectAnimationWithFade(_ cell: YMMonthDayCollectionCell) {
        
    }
    
    func deselectAnimationWithFade(_ cell: YMMonthDayCollectionCell) {
        
    }
}
