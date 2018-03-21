//
//  YMEventsRowViewDelegate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/10.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

internal protocol YMEventsRowViewDelegate: UIScrollViewDelegate {
    func eventsRowView(_ view: YMEventsRowView, numberOfEventsAt day: Int) -> Int
    func eventsRowView(_ view: YMEventsRowView, rangeForEventAtIndexPath indexPath: IndexPath) -> NSRange
    func eventsRowView(_ view: YMEventsRowView, styleForEventViewAt indexPath: IndexPath) -> Style<UIView>
    func eventsRowView(_ view: YMEventsRowView, shouldSelectCellAtIndexPath indexPath: IndexPath) -> Bool
    func eventsRowView(_ view: YMEventsRowView, shouldDeselectCellAtIndexPath indexPath: IndexPath) -> Bool
    func eventsRowView(_ view: YMEventsRowView, didSelectCellAtIndexPath indexPath: IndexPath)
    func eventsRowView(_ view: YMEventsRowView, didDeselectCellAtIndexPath  indexPath: IndexPath)
}
