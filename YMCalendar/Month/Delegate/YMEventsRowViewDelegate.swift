//
//  YMEventsRowViewDelegate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/10.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

@objc internal protocol YMEventsRowViewDelegate: UIScrollViewDelegate {
    func eventsRowView(_ view: YMEventsRowView, numberOfEventsForDayAtIndex day: Int) -> Int
    func eventsRowView(_ view: YMEventsRowView, rangeForEventAtIndexPath indexPath: IndexPath) -> NSRange
    func eventsRowView(_ view: YMEventsRowView, cellForEventAtIndexPath indexPath: IndexPath) -> YMEventView
    
    @objc optional func eventsRowView(_ view: YMEventsRowView, widthForDayRange range: NSRange) -> CGFloat
    @objc optional func eventsRowView(_ view: YMEventsRowView, shouldSelectCellAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func eventsRowView(_ view: YMEventsRowView, shouldDeselectCellAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func eventsRowView(_ view: YMEventsRowView, didSelectCellAtIndexPath indexPath: IndexPath)
    @objc optional func eventsRowView(_ view: YMEventsRowView, didDeselectCellAtIndexPath  indexPath: IndexPath)
    @objc optional func eventsRowView(_ view: YMEventsRowView, willDisplayCell cell: YMEventView, forEventAtIndexPath indexPath: IndexPath)
    @objc optional func eventsRowView(_ view: YMEventsRowView, didEndDidsplayingCell cell: YMEventView, forEventAtIndexPath indexPath: IndexPath)
}
