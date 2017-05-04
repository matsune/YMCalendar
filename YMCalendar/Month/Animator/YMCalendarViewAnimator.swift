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
    var selectAnimation: YMCalendarSelectionAnimation { get set }
    var deselectAnimation: YMCalendarSelectionAnimation { get set }
}
