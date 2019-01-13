//
//  YMEventsRowView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final class YMEventsRowView: UIScrollView {

    weak var eventsRowDelegate: YMEventsRowViewDelegate?

    var monthStart: Date!

    var daysRange = NSRange()

    var dayWidth: CGFloat = 100

    var itemHeight: CGFloat = 18

    let cellSpacing: CGFloat = 2.0

    var eventViews: [IndexPath: UIView] = [:]

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
    }

    private func removeAllEventViews() {
        eventViews.forEach { $0.value.removeFromSuperview() }
        eventViews.removeAll()
    }

    func reload() {
        removeAllEventViews()

        var lines = [IndexSet]()

        for day in daysRange.location..<NSMaxRange(daysRange) {
            for item in 0..<(eventsRowDelegate?.eventsRowView(self, numberOfEventsAt: day) ?? 0) {
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
        let view = UIView()
        view.frame = rectForCell(range: range, line: line)
        if let style = eventsRowDelegate?.eventsRowView(self, styleForEventViewAt: indexPath) {
            view.apply(style)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        view.setNeedsDisplay()
        eventViews[indexPath] = view
        addSubview(view)
    }

    func viewsInRect(_ rect: CGRect) -> [UIView] {
        var rows: [UIView] = []
        eventViews.forEach { _, cell in
            if cell.frame.intersects(rect) {
                rows.append(cell)
            }
        }
        return rows
    }

    func indexPathForCellAtPoint(_ point: CGPoint) -> IndexPath? {
        for (indexPath, cell) in eventViews {
            if cell.frame.contains(point) {
                return indexPath
            }
        }
        return nil
    }

    func eventView(at indexPath: IndexPath) -> UIView? {
        return eventViews[indexPath]
    }

    private func rectForCell(range: NSRange, line: Int) -> CGRect {
        let colStart = range.location - daysRange.location

        let x = dayWidth * CGFloat(colStart)
        let y = CGFloat(line) * (itemHeight + cellSpacing)
        let w = dayWidth * CGFloat(range.length)
        let rect = CGRect(x: x, y: y, width: w, height: itemHeight)
        return rect.insetBy(dx: cellSpacing, dy: 0)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }

    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        if let indexPath = eventViews.first(where: { $0.value == gesture.view })?.key {
            eventsRowDelegate?.eventsRowView(self, didSelectCellAtIndexPath: indexPath)
        }
    }
}
