//
//  YMEventsRowView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final class YMEventsRowView: UIScrollView, ReusableObject {

    weak var eventsRowDelegate: YMEventsRowViewDelegate?
    
    var reuseIdentifier: String = ""
    
    var referenceDate: Date = Date()
    
    var daysRange: NSRange = NSRange()
    
    var dayWidth: CGFloat = 100
    
    var itemHeight: CGFloat = 18
    
    let cellSpacing: CGFloat = 2.0
    
    
    var cells: [IndexPath : YMEventView] = [:]
    var labels: [UILabel] = []
    var eventsCount: [Int : Int]? = nil
    
    
    var maxVisibleLines: Int {
        return Int((bounds.height + cellSpacing + 1) / (itemHeight + cellSpacing))
    }
    
    var eventRanges: [IndexPath : NSRange] {
        var eventRanges: [IndexPath : NSRange] = [:]
        var day = daysRange.location
        
        while day < NSMaxRange(daysRange) {
            let eventsCount = numberOfEventsForDayAtIndex(day)
            
            for item in 0..<eventsCount {
                let path = IndexPath(item: item, section: day)
                if let eventRange = eventsRowDelegate?.eventsRowView(self, rangeForEventAtIndexPath: path) {
                    if eventRange.location == day || day == daysRange.location {
                        let rangeEventInRow = NSIntersectionRange(eventRange, daysRange)
                        eventRanges[path] = rangeEventInRow
                    }
                }
            }
            day += 1
        }
        return eventRanges
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        contentSize = CGSize(width: frame.width, height: 400)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reload()
    }
    
    func maxVisibleLinesForDaysInRange(_ range: NSRange) -> Int {
        var count = 0
        for day in range.location..<NSMaxRange(range) {
            count = max(count, numberOfEventsForDayAtIndex(day))
        }
        return count > maxVisibleLines ? maxVisibleLines : count
    }
    
    func numberOfEventsForDayAtIndex(_ day: Int) -> Int {
        var count = eventsCount?[day]
        if let count = count {
            return count
        } else {
            let numEvents = eventsRowDelegate?.eventsRowView(self, numberOfEventsForDayAtIndex: day) ?? 0
            count = numEvents
            if eventsCount == nil {
                eventsCount = [:]
            }
            eventsCount![day] = count!
            return count!
        }
    }
    
    
    func reload() {
        recycleEventsCells()
        eventsCount = nil
        
        var daysWithMoreEvents: [Int : Int] = [:]
        var lines = [IndexSet]()
        
        eventRanges
            .sorted(by: {$0.0.value.location < $0.1.value.location})
            .forEach { indexPath, range in
            
                var numLine = -1
            
                for i in 0..<lines.count {
                    let indexes = lines[i]
                    if !indexes.intersects(integersIn: range.toRange()!) {
                        numLine = i
                        break
                    }
                }
                if numLine == -1 {
                    numLine = lines.count
                    lines.append(IndexSet(integersIn: range.toRange()!))
                } else {
                    lines[numLine].insert(integersIn: range.toRange()!)
                }
                
                let maxVisibleEvents = maxVisibleLinesForDaysInRange(range)
                if numLine < maxVisibleEvents {
                    if let cell = eventsRowDelegate?.eventsRowView(self, cellForEventAtIndexPath: indexPath) {
                        cell.frame = rectForCellWithRange(range, line: numLine)
                        eventsRowDelegate?.eventsRowView?(self, willDisplayCell: cell, forEventAtIndexPath: indexPath)
                        addSubview(cell)
                        cell.setNeedsDisplay()
                        
                        cells[indexPath] = cell
                    }
                } else {
                    for day in range.location..<NSMaxRange(range) {
                        if let daysCount = daysWithMoreEvents[day] {
                            var count = daysCount
                            count += 1
                            daysWithMoreEvents[day] = count
                        }
                    }
                }
                
                for day in range.location..<NSMaxRange(range) {
                    if let hiddenCount = daysWithMoreEvents[day], hiddenCount > 0 {
                        let label = UILabel(frame: .zero)
                        label.text = "\(hiddenCount) more.."
                        label.textColor = .gray
                        label.textAlignment = .right
                        label.font = .systemFont(ofSize: 11)
                        label.frame = rectForCellWithRange(NSRange(location: day, length: 1), line: maxVisibleLines - 1)
                        
                        addSubview(label)
                        labels.append(label)
                    }
                }
            }
    }
    
    func cellsInRect(_ rect: CGRect) -> [YMEventView] {
        var rows: [YMEventView] = []
        cells.forEach { indexPath, cell in
            if cell.frame.intersects(rect) {
                rows.append(cell)
            }
        }
        return rows
    }
    
    func indexPathForCellAtPoint(_ point: CGPoint) -> IndexPath? {
        for (indexPath, cell) in cells {
            if cell.frame.contains(point) {
                return indexPath
            }
        }
        return nil
    }
    
    func cellAtIndexPath(_ indexPath: IndexPath) -> YMEventView? {
        return cells[indexPath]
    }
    
    func prepareForReuse() {
        recycleEventsCells()
    }
    
    func recycleEventsCells() {
        cells.forEach { indexPath, cell in
            cell.removeFromSuperview()
            
            eventsRowDelegate?.eventsRowView?(self, didEndDidsplayingCell: cell, forEventAtIndexPath: indexPath)
        }
        cells.removeAll()
        
        labels.forEach {$0.removeFromSuperview()}
        labels.removeAll()
    }

    func rectForCellWithRange(_ range: NSRange, line: Int) -> CGRect {
        let colStart = range.location - daysRange.location
        
        var x = dayWidth * CGFloat(colStart)
        if let width = eventsRowDelegate?.eventsRowView?(self, widthForDayRange: NSRange(location: 0, length: colStart)) {
            x = width
        }
        let y = CGFloat(line) * (itemHeight + cellSpacing)
        var w = dayWidth * CGFloat(range.length)
        if let width = eventsRowDelegate?.eventsRowView?(self, widthForDayRange: NSRange(location: 0, length: range.length)) {
            w = width
        }
        let rect = CGRect(x: x, y: y, width: w, height: itemHeight)
        return rect.insetBy(dx: cellSpacing, dy: 0)
    }
    
    

    func didTapCell(_ cell: YMEventView, atIndexPath indexPath: IndexPath) {
        if cell.selected {
            var shouldDeselect = true
            if let deselect = eventsRowDelegate?.eventsRowView?(self, shouldSelectCellAtIndexPath: indexPath) {
                shouldDeselect = deselect
            }
            if shouldDeselect {
                cell.selected = false
                eventsRowDelegate?.eventsRowView?(self, didDeselectCellAtIndexPath: indexPath)
            }
        } else {
            var shouldSelect = true
            if let select = eventsRowDelegate?.eventsRowView?(self, shouldSelectCellAtIndexPath: indexPath) {
                shouldSelect = select
            }
            if shouldSelect {
                cell.selected = true
                eventsRowDelegate?.eventsRowView?(self, didSelectCellAtIndexPath: indexPath)
            }
        }
    }
    
    
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        let pt = recognizer.location(in: self)
        for (indexPath, cell) in cells {
            if cell.frame.contains(pt) {
                didTapCell(cell, atIndexPath: indexPath)
                break
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
