//
//  YMEventsRowView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final internal class YMEventsRowView: UIScrollView {

    weak var eventsRowDelegate: YMEventsRowViewDelegate?
    
    var monthStart: Date!
    
    var daysRange = NSRange()
    
    var dayWidth: CGFloat = 100
    
    var itemHeight: CGFloat = 18
    
    let cellSpacing: CGFloat = 2.0
    
    var cells: [IndexPath: YMEventView] = [:]
    
    var eventsCount: [Int: Int] = [:]
    
    var maxVisibleLines: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentSize = CGSize(width: frame.width, height: 400)
        clipsToBounds = true
        backgroundColor  = .clear
        showsVerticalScrollIndicator   = false
        showsHorizontalScrollIndicator = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    func numberOfEventsAt(day: Int) -> Int {
        if let count = eventsCount[day] {
            return count
        } else {
            let numEvents = eventsRowDelegate?.eventsRowView(self, numberOfEventsAt: day) ?? 0
            eventsCount[day] = numEvents
            return numEvents
        }
    }
    
    private func removeAllEventViews() {
        cells.forEach { $0.value.removeFromSuperview() }
        cells.removeAll()
        eventsCount.removeAll()
    }
    
    func reload() {
        removeAllEventViews()
        
        var lines = [IndexSet]()
        
        for day in daysRange.location..<NSMaxRange(daysRange) {
            for item in 0..<numberOfEventsAt(day: day) {
                let indexPath = IndexPath(item: item, section: day)
                
                guard let eventRange = eventsRowDelegate?.eventsRowView(self, rangeForEventAtIndexPath: indexPath),
                    eventRange.location == day || day == daysRange.location else {
                    continue
                }
                let range = NSIntersectionRange(eventRange, daysRange)
                
                var numLine = -1
                for i in 0..<lines.count {
                    let indexes = lines[i]
                    if !indexes.intersects(integersIn: Range(range)!) {
                        numLine = i
                        break
                    }
                }
                if numLine == -1 {
                    numLine = lines.count
                    lines.append(IndexSet(integersIn: Range(range)!))
                } else {
                    lines[numLine].insert(integersIn: Range(range)!)
                }
                
                if let maxVisibleEvents = maxVisibleLines {
                    if numLine < maxVisibleEvents {
                        createEventView(range: range, line: numLine, indexPath: indexPath)
                    }
                } else {
                    createEventView(range: range, line: numLine, indexPath: indexPath)
                }
            }
        }

        let lineCount = min(maxVisibleLines ?? lines.count, lines.count)
        contentSize = CGSize(width: bounds.width, height: (cellSpacing + itemHeight) * CGFloat(lineCount))
    }
    
    private func createEventView(range: NSRange, line: Int, indexPath: IndexPath) {
        let view = YMEventView()
        view.frame = rectForCell(range: range, line: line)
        if let style = eventsRowDelegate?.eventsRowView(self, styleForEventViewAt: indexPath) {
            view.apply(style)
        }
        view.setNeedsDisplay()
        cells[indexPath] = view
        addSubview(view)
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

    private func rectForCell(range: NSRange, line: Int) -> CGRect {
        let colStart = range.location - daysRange.location
        
        let x = dayWidth * CGFloat(colStart)
        let y = CGFloat(line) * (itemHeight + cellSpacing)
        let w = dayWidth * CGFloat(range.length)
        let rect = CGRect(x: x, y: y, width: w, height: itemHeight)
        return rect.insetBy(dx: cellSpacing, dy: 0)
    }
    
    func didTapCell(_ cell: YMEventView, atIndexPath indexPath: IndexPath) {
        if cell.selected {
            var shouldDeselect = true
            if let deselect = eventsRowDelegate?.eventsRowView(self, shouldSelectCellAtIndexPath: indexPath) {
                shouldDeselect = deselect
            }
            if shouldDeselect {
                cell.selected = false
                eventsRowDelegate?.eventsRowView(self, didDeselectCellAtIndexPath: indexPath)
            }
        } else {
            var shouldSelect = true
            if let select = eventsRowDelegate?.eventsRowView(self, shouldSelectCellAtIndexPath: indexPath) {
                shouldSelect = select
            }
            if shouldSelect {
                cell.selected = true
                eventsRowDelegate?.eventsRowView(self, didSelectCellAtIndexPath: indexPath)
            }
        }
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
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
