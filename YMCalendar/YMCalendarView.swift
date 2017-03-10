//
//  YMCalendarView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public final class YMCalendarView: UIView, YMCalendarAppearance {
    
    weak var appearance: YMCalendarAppearance?

    weak var delegate: YMCalendarDelegate?
    
    weak var dataSource: YMCalendarDataSource?
    
    var calendar = Calendar.current
    
    var collectionView: UICollectionView!
    
    var eventRows: [Date : YMEventsRowView] = [:]
    
    let itemHeight: CGFloat = 16
    
    let rowCacheSize = 40
    
    var reuseQueue = ReusableObjectQueue()
    
    var allowsSelection: Bool = true
    
    var dateRange: DateRange?
    
    var visibleMonths: DateRange?
    
    var didLayout: Bool = false
    
    var dayHeaderHeight: CGFloat = 15 {
        didSet {
            layout.dayHeaderHeight = dayHeaderHeight
            collectionView.reloadData()
        }
    }

    var layout: YMCalendarLayout {
        set {
            collectionView.collectionViewLayout = newValue
        }
        get {
            return collectionView.collectionViewLayout as! YMCalendarLayout
        }
    }
    
    var isPagingEnabled: Bool {
        set {
            collectionView.isPagingEnabled = newValue
        }
        get {
            return collectionView.isPagingEnabled
        }
    }
    
    var decelerationRate: YMDecelerationRate = .normal {
        didSet {
            collectionView.decelerationRate = decelerationRate.value
        }
    }
    
    var scrollDirection: YMScrollDirection = .vertical {
        didSet {
            let monthLayout = YMCalendarLayout(scrollDirection: scrollDirection)
            monthLayout.delegate = self
            monthLayout.monthInsets = monthInsets
            monthLayout.dayHeaderHeight = dayHeaderHeight
            layout = monthLayout
        }
    }
    
    var startDate: Date {
        didSet {
            if startDate != oldValue {
                startDate = calendar.startOfMonthForDate(startDate)
            }
        }
    }
    
    override public var backgroundColor: UIColor? {
        didSet {
            if collectionView != nil {
                collectionView.backgroundColor = backgroundColor
            }
        }
    }
    
    var monthInsets: UIEdgeInsets = .zero {
        didSet {
            layout.monthInsets = monthInsets
            setNeedsLayout()
        }
    }
    
    var selectedEventDate: Date?
    
    var selectedEventIndex: Int = 0
    
    fileprivate var numberOfLoadedMonths: Int {
        var numMonths = 9
        let minContentHeight = collectionView.bounds.height + 2 * collectionView.bounds.height
        let minLoadedMonths = Int(ceil(minContentHeight / collectionView.bounds.height))
        numMonths = max(numMonths, minLoadedMonths)
        return numMonths
    }
    
    var visibleDateRange = DateRange()
    
    var visibleDays: DateRange? {
        collectionView.layoutIfNeeded()
        var range: DateRange? = nil
        
        let visible = collectionView.indexPathsForVisibleItems.sorted()
        if let firstIdx = visible.first, let lastIdx = visible.last, !visible.isEmpty {
            let first = dateForDayAtIndexPath(firstIdx)
            var last  = dateForDayAtIndexPath(lastIdx)
            
            last = calendar.date(byAdding: .day, value: 1, to: last)!
            range = DateRange(start: first, end: last)
        }
        return range
    }
    
    var loadedDateRange: DateRange {
        var comps = DateComponents()
        comps.month = numberOfLoadedMonths
        let endDate = calendar.date(byAdding: comps, to: startDate)
        return DateRange(start: startDate, end: endDate!)
    }
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        startDate = calendar.startOfMonthForDate(Date())
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        startDate = calendar.startOfMonthForDate(Date())
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        reuseQueue.registerClass(ReusableIdentifier.Events.rowView.classType, forObjectWithReuseIdentifier: ReusableIdentifier.Events.rowView.identifier)

        let monthLayout = YMCalendarLayout(scrollDirection: scrollDirection)
        monthLayout.delegate = self
        monthLayout.monthInsets = monthInsets
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: monthLayout)
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.isPagingEnabled = isPagingEnabled
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        
        collectionView.register(ReusableIdentifier.Month.DayCell.classType, forCellWithReuseIdentifier: ReusableIdentifier.Month.DayCell.identifier)
        collectionView.register(ReusableIdentifier.Month.BackgroundView.classType, forSupplementaryViewOfKind: ReusableIdentifier.Month.BackgroundView.kind, withReuseIdentifier: ReusableIdentifier.Month.BackgroundView.identifier)
        collectionView.register(ReusableIdentifier.Month.RowView.classType, forSupplementaryViewOfKind: ReusableIdentifier.Month.RowView.kind, withReuseIdentifier: ReusableIdentifier.Month.RowView.identifier)
        
        addSubview(collectionView)
    }
    
    
    // MARK: - UIView
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    override public func draw(_ rect: CGRect) {
        collectionView.contentInset = .zero
        
        if !didLayout {
            recenterIfNeeded()
            didLayout = true
        }
        
        super.draw(rect)
    }
    
}

extension YMCalendarView {
    // MARK: - Utils
    
    func dateForDayAtIndexPath(_ indexPath: IndexPath) -> Date {
        var comp   = DateComponents()
        comp.month = indexPath.section
        comp.day   = indexPath.row
        return calendar.date(byAdding: comp, to: startDate)!
    }
    
    func indexPathForDate(_ date: Date) -> IndexPath? {
        var indexPath: IndexPath? = nil
        if loadedDateRange.contains(date: date) {
            let comps = calendar.dateComponents([.month, .day], from: startDate, to: date)
            guard let day = comps.day, let month = comps.month else {
                return nil
            }
            indexPath = IndexPath(item: day, section: month)
        }
        return indexPath
    }
    
    func indexPathsForDaysInRange(_ range: DateRange) -> [IndexPath] {
        var paths: [IndexPath] = []
        var comps = DateComponents()
        comps.day = 0
        
        var date = calendar.startOfDay(for: range.start)
        while range.contains(date: date) {
            if let path = indexPathForDate(date) {
                paths.append(path)
            }
            
            guard let day = comps.day else {
                return paths
            }
            comps.day = day + 1
            date = calendar.date(byAdding: comps, to: range.start)!
        }
        return paths
    }
    
    func dateStartingMonthAtIndex(_ month: Int) -> Date {
        return dateForDayAtIndexPath(IndexPath(item: 0, section: month))
    }
    
    func numberOfDaysForMonthAtMonth(_ month: Int) -> Int {
        let date = dateStartingMonthAtIndex(month)
        return calendar.numberOfDaysInMonthForDate(date)
    }
    
    func columnForDayAtIndexPath(_ indexPath: IndexPath) -> Int {
        let date = dateForDayAtIndexPath(indexPath)
        var weekday = calendar.component(.weekday, from: date)
        weekday = (weekday + 7 - calendar.firstWeekday) % 7
        return weekday
    }
    
    func dateRangeForYMEventsRowView(_ rowView: YMEventsRowView) -> DateRange {
        let start = calendar.date(byAdding: .day, value: rowView.daysRange.location, to: rowView.referenceDate)
        let end = calendar.date(byAdding: .day, value: NSMaxRange(rowView.daysRange), to: rowView.referenceDate)
        return DateRange(start: start!, end: end!)
    }
    
    func offsetForMonth(date: Date) -> CGFloat {
        let startOfMonth = calendar.startOfMonthForDate(date)
        
        let comps = calendar.dateComponents([.month], from: startDate, to: startOfMonth)
        let monthsDiff = labs(comps.month!)
        
        var offset: CGFloat = 0
        
        var month = (startOfMonth as NSDate).earlierDate(startDate)
        for _ in 0..<monthsDiff {
            offset += scrollDirection == .vertical ? collectionView.bounds.height : collectionView.bounds.width
            month = calendar.date(byAdding: .month, value: 1, to: month)!
        }
        
        if startOfMonth.compare(startDate) == .orderedAscending {
            offset = -offset
        }
        return offset
    }
    
    func monthFromOffset(_ offset: CGFloat) -> Date {
        var month = startDate
        if scrollDirection == .vertical {
            var y = offset > 0 ? collectionView.bounds.height : 0
            
            while y < fabs(offset) {
                month = calendar.date(byAdding: .month, value: offset > 0 ? 1 : -1, to: month)!
                y += collectionView.bounds.height
            }
        } else {
            var x = offset > 0 ? collectionView.bounds.width : 0
            
            while x < fabs(offset) {
                month = calendar.date(byAdding: .month, value: offset > 0 ? 1 : -1, to: month)!
                x += collectionView.bounds.width
            }
        }
        return month
    }
    
    func reload() {
        deselectEventWithDelegate(true)
        
        clearRowsCacheInDateRange(nil)
        collectionView.reloadData()
    }
    
    func maxSizeForFont(_ font: UIFont, toFitStrings strings: [String], inSize size: CGSize) -> CGFloat {
        let context = NSStringDrawingContext()
        context.minimumScaleFactor = 0.1
        
        var fontSize = font.pointSize
        for str in strings {
            let attrStr = NSAttributedString(string: str, attributes: [NSFontAttributeName : font])
            attrStr.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: context)
            fontSize = min(fontSize, font.pointSize * context.actualScaleFactor)
        }
        return floor(fontSize)
    }
}

extension YMCalendarView {
    // MARK: - Public
    func registerClass(_ objectClass: ReusableObject.Type, forEventCellReuseIdentifier identifier: String) {
        reuseQueue.registerClass(objectClass, forObjectWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCellWithIdentifier<T: YMEventView>(_ identifier: String, forEventAtIndex index: Int, date: Date) -> T? {
        let cell: T? = reuseQueue.dequeueReusableObjectWithIdentifier(identifier)
        if let selectedDate = selectedEventDate, calendar.isDate(selectedDate, inSameDayAs: date) && index == selectedEventIndex {
            cell?.selected = true
        }
        return cell
    }
    
    func reloadEvents() {
        deselectEventWithDelegate(true)
        guard let visibleDateRange = visibleDays else {
            return
        }
        eventRows.forEach { date, rowView in
            let rowRange = dateRangeForYMEventsRowView(rowView)
            if rowRange.intersectsDateRange(visibleDateRange) {
                rowView.reload()
            } else {
                removeRowAtDate(date)
            }
        }
    }
    
    func reloadEventsAtDate(_ date: Date) {
        if let selectedEventDate = selectedEventDate, calendar.isDate(selectedEventDate, inSameDayAs: date) {
            deselectEventWithDelegate(true)
        }
        if let visibleDateRange = visibleDays {
            eventRows.forEach { date, rowView in
                let rowRange = dateRangeForYMEventsRowView(rowView)
                if rowRange.contains(date: date) {
                    if visibleDateRange.contains(date: date) {
                        rowView.reload()
                    } else {
                        removeRowAtDate(date)
                    }
                }
            }
        }
    }
    
    func reloadEventsInRange(_ range: DateRange) {
        if let selectedEventDate = selectedEventDate, range.contains(date: selectedEventDate) {
            deselectEventWithDelegate(true)
        }
        if let visibleDateRange = visibleDays {
            eventRows.forEach({ date, rowView in
                let rowRange = dateRangeForYMEventsRowView(rowView)
                if rowRange.intersectsDateRange(range) {
                    if rowRange.intersectsDateRange(visibleDateRange) {
                        rowView.reload()
                    } else {
                        removeRowAtDate(date)
                    }
                }
            })
        }
    }
    
    var visibleEventCells: [YMEventView] {
        var cells: [YMEventView] = []
        for rowView in visibleEventRows {
            let rect = rowView.convert(bounds, from: self)
            cells.append(contentsOf: rowView.cellsInRect(rect))
        }
        return cells
    }
    
    func cellForEventAtIndex(_ index: Int, date: Date) -> YMEventView? {
        for rowView in visibleEventRows {
            guard let day = calendar.dateComponents([.day], from: rowView.referenceDate, to: date).day else {
                return nil
            }
            if NSLocationInRange(day, rowView.daysRange) {
                return rowView.cellAtIndexPath(IndexPath(item: index, section: day))
            }
        }
        return nil
    }
    
    func eventCellAtPoint(_ pt: CGPoint, date: inout Date, index: inout Int) -> YMEventView? {
        for rowView in visibleEventRows {
            let ptInRow = rowView.convert(pt, from: self)
            if let path = rowView.indexPathForCellAtPoint(ptInRow) {
                var comps = DateComponents()
                comps.day = path.section
                date = calendar.date(byAdding: comps, to: rowView.referenceDate)!
                index = path.item
                return rowView.cellAtIndexPath(path)
            }
        }
        return nil
    }
    
    func dayAtPoint(_ point: CGPoint) -> Date? {
        let pt = collectionView.convert(point, from: self)
        if let indexPath = collectionView.indexPathForItem(at: pt) {
            return dateForDayAtIndexPath(indexPath)
        }
        return nil
    }
}

extension YMCalendarView {
    // MARK: - Selection
    
    var selectedEventView: YMEventView? {
        if let date = selectedEventDate {
            return cellForEventAtIndex(selectedEventIndex, date: date)
        }
        return nil
    }
    
    func deselectEventWithDelegate(_ tellDelegate: Bool) {
        if let selectedDate = selectedEventDate {
            let cell = cellForEventAtIndex(selectedEventIndex, date: selectedDate)
            cell?.selected = false
            
            if tellDelegate {
                delegate?.monthView?(self, didDeselectEventAtIndex: selectedEventIndex, date: selectedDate)
            }
            
            selectedEventDate = nil
        }
    }
    
    func deselectEvent() {
        if allowsSelection {
            deselectEventWithDelegate(false)
        }
    }
    
    func selectEventCellAtIndex(_ index: Int, date: Date) {
        deselectEventWithDelegate(false)
        
        if allowsSelection {
            let cell = cellForEventAtIndex(index, date: date)
            cell?.selected = true
            
            selectedEventDate  = date
            selectedEventIndex = index
        }
    }
}

extension YMCalendarView {
    // MARK: - Scrolling
    
    func scrollToDate(_ date: Date, animated: Bool) {
        scrollToDate(date, alignment: .headerTop, animated: animated)
    }
    
    func scrollToDate(_ date: Date, alignment: YMScrollAlignment, animated: Bool) {
        if let dateRange = dateRange, !dateRange.contains(date: date) {
            fatalError()
        }
        
        var offset = offsetForMonth(date: date)
        if scrollDirection == .vertical {
            offset += monthInsets.top
            
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
        } else {
            offset += monthInsets.left
            
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }
        
        delegate?.calendarViewDidScroll?(self)
    }
    
    func adjustStartDateForCenteredMonth(date: Date) -> Int {
        let offset: Int
        if scrollDirection == .vertical {
            let contentHeight = collectionView.contentSize.height
            let boundsHeight = collectionView.bounds.height
            offset = Int(floor((contentHeight - boundsHeight) / collectionView.bounds.height) / 2)
        } else {
            let contentWidth = collectionView.contentSize.width
            let boundsWidth = collectionView.bounds.width
            offset = Int(floor((contentWidth - boundsWidth) / collectionView.bounds.width) / 2)
        }
        
        guard let start = calendar.date(byAdding: .month, value: -offset, to: date),
            let diff = calendar.dateComponents([.month], from: startDate, to: start).month else {
                fatalError()
        }
        
        self.startDate = start
        return diff
    }
    
    func recenterIfNeeded() {
        if collectionView.bounds.height == 0 {
            collectionView.contentOffset = .zero
            collectionView.contentInset = .zero
            layoutIfNeeded()
        }
        
        if scrollDirection == .vertical {
            let yOffset = collectionView.contentOffset.y
            let contentHeight = collectionView.contentSize.height
            let monthMaxHeight = collectionView.bounds.height
            
            if yOffset < monthMaxHeight || collectionView.bounds.maxY + monthMaxHeight > contentHeight {
                let oldStart = startDate
                
                let centerMonth = monthFromOffset(yOffset)
                let monthOffset = adjustStartDateForCenteredMonth(date: centerMonth)
                
                if monthOffset != 0 {
                    let y = offsetForMonth(date: oldStart)
                    collectionView.reloadData()
                    
                    var offset = collectionView.contentOffset
                    offset.y = y + yOffset
                    collectionView.contentOffset = offset
                }
            }
        } else {
            let xOffset = collectionView.contentOffset.x
            let contentWidth = collectionView.contentSize.width
            let monthMaxWidth = collectionView.bounds.width
            
            if xOffset < monthMaxWidth || collectionView.bounds.maxX + monthMaxWidth > contentWidth {
                let oldStart = startDate
                
                let centerMonth = monthFromOffset(xOffset)
                let monthOffset = adjustStartDateForCenteredMonth(date: centerMonth)
                
                if monthOffset != 0 {
                    let x = offsetForMonth(date: oldStart)
                    collectionView.reloadData()
                    
                    var offset = collectionView.contentOffset
                    offset.x = x + xOffset
                    collectionView.contentOffset = offset
                }
            }
        }
    }
}

extension YMCalendarView {
    // MARK: - Rows Handling
    var visibleEventRows: [YMEventsRowView] {
        var rows: [YMEventsRowView] = []
        if let visibleRange = visibleDays {
            for hash in eventRows {
                if visibleRange.contains(date: hash.key) {
                    rows.append(hash.value)
                }
            }
        }
        return rows
    }
    
    func clearRowsCacheInDateRange(_ range: DateRange?) {
        if let range = range {
            for hash in eventRows {
                if range.contains(date: hash.key) {
                    removeRowAtDate(hash.key)
                }
            }
        } else {
            for hash in eventRows {
                removeRowAtDate(hash.key)
            }
        }
    }
    
    func removeRowAtDate(_ date: Date) {
        if let remove = eventRows[date] {
            reuseQueue.enqueueReusableObject(remove)
            eventRows.removeValue(forKey: date)
        }
    }
    
    func YMEventsRowViewAtDate(_ rowStart: Date) -> YMEventsRowView {
        var YMEventsRowView: YMEventsRowView? = eventRows[rowStart]
        if YMEventsRowView == nil {
            YMEventsRowView = reuseQueue.dequeueReusableObjectWithIdentifier(ReusableIdentifier.Events.rowView.identifier)
            let referenceDate = calendar.startOfMonthForDate(rowStart)
            let first = calendar.dateComponents([.day], from: referenceDate, to: rowStart).day
            if let range = calendar.range(of: .day, in: .weekOfMonth, for: rowStart) {
                let numDays = range.upperBound - range.lowerBound
                
                YMEventsRowView?.referenceDate = referenceDate
                YMEventsRowView?.isScrollEnabled = false
                YMEventsRowView?.itemHeight = itemHeight
                YMEventsRowView?.eventsRowDelegate = self
                YMEventsRowView?.daysRange = NSMakeRange(first!, numDays)
                YMEventsRowView?.dayWidth = bounds.width / 7
                
                YMEventsRowView?.reload()
            }
        }
        cacheRow(YMEventsRowView!, forDate: rowStart)
        return YMEventsRowView!
    }
    
    func cacheRow(_ eventsView: YMEventsRowView, forDate date: Date) {
        if let _ = eventRows[date] {
            eventRows.removeValue(forKey: date)
        }
        eventRows[date] = eventsView
        
        if eventRows.count >= rowCacheSize {
            if let first = eventRows.map({$0.key}).first {
                removeRowAtDate(first)
            }
        }
    }
    
    func monthRowViewForAtIndexPath(_ indexPath: IndexPath) -> YMMonthWeekView {
        let rowStart = dateForDayAtIndexPath(indexPath)
        guard let rowView = collectionView.dequeueReusableSupplementaryView(ofKind: ReusableIdentifier.Month.RowView.kind, withReuseIdentifier: ReusableIdentifier.Month.RowView.identifier, for: indexPath) as? YMMonthWeekView else {
            fatalError()
        }
        let eventsView = YMEventsRowViewAtDate(rowStart)
        
        rowView.eventsView = eventsView
        return rowView
    }
}

extension YMCalendarView: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    // 読み込む月の数
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfLoadedMonths
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDaysForMonthAtMonth(section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableIdentifier.Month.DayCell.identifier, for: indexPath) as? YMMonthDayCollectionCell else {
            fatalError()
        }
        let date = dateForDayAtIndexPath(indexPath)
        
        cell.setDay(calendar.day(date))
        
        return cell
    }
    
    func backgroundViewForAtIndexPath(_ indexPath: IndexPath) -> UICollectionReusableView {
        let date = dateStartingMonthAtIndex(indexPath.section)
        
        
        let lastColumn: Int = columnForDayAtIndexPath(IndexPath(item: 0, section: indexPath.section + 1))
        let numRows: Int = calendar.numberOfWeeksInMonthForDate(date)
        
        guard let view = collectionView
            .dequeueReusableSupplementaryView(ofKind: ReusableIdentifier.Month.BackgroundView.kind,
                                              withReuseIdentifier: ReusableIdentifier.Month.BackgroundView.identifier,
                                              for: indexPath) as? YMMonthBackgroundView else {
                                                fatalError()
        }
        view.setAppearance(appearance ?? self, numberOfColumns: 7, numberOfRows: numRows, lastColumn: lastColumn)
        view.setNeedsDisplay()
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case ReusableIdentifier.Month.BackgroundView.kind:
            return backgroundViewForAtIndexPath(indexPath)
        case ReusableIdentifier.Month.RowView.kind:
            return monthRowViewForAtIndexPath(indexPath)
        default:
            fatalError()
        }
    }
}

extension YMCalendarView: YMEventsRowViewDelegate {
    // MARK: - YMEventsRowViewDelegate
    func eventsRowView(_ view: YMEventsRowView, numberOfEventsForDayAtIndex day: Int) -> Int {
        var comps = DateComponents()
        comps.day = day
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate),
        let count = dataSource?.calendarView(self, numberOfEventsAtDate: date) else {
            return 0
        }
        return count
    }
    
    func eventsRowView(_ view: YMEventsRowView, rangeForEventAtIndexPath indexPath: IndexPath) -> NSRange {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate),
            let dateRange = dataSource?.calendarView(self, dateRangeForEventAtIndex: indexPath.item, date: date) else {
            return NSRange()
        }
        
        let start = max(0, calendar.dateComponents([.day], from: view.referenceDate, to: dateRange.start).day!)
        var end = calendar.dateComponents([.day], from: view.referenceDate, to: dateRange.end).day!
        if dateRange.end.timeIntervalSince(calendar.startOfDay(for: dateRange.end)) >= 0 {
            end += 1
        }
        end = min(end, NSMaxRange(view.daysRange))
        return NSMakeRange(start, end - start)
    }
    func eventsRowView(_ view: YMEventsRowView, cellForEventAtIndexPath indexPath: IndexPath) -> YMEventView?  {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate) else {
            return nil
        }
        return dataSource?.calendarView(self, cellForEventAtIndex: indexPath.item, date: date)
    }
}

extension YMCalendarView: YMCalendarLayoutDelegate {
    // MARK: - MonthLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout: YMCalendarLayout, columnForDayAtIndexPath indexPath: IndexPath) -> Int {
        return columnForDayAtIndexPath(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = dateForDayAtIndexPath(indexPath)
        delegate?.calendarView?(self, didSelectDayCellAtDate: date)
        
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: selectedIndex, animated: true)
        }
    }
    
    var visibleMonthRange: DateRange? {
        var visibleMonths: DateRange? = nil
        let visibleDaysRange = visibleDays
        if let visibleDaysRange = visibleDaysRange {
            let start = calendar.startOfMonthForDate(visibleDaysRange.start)
            let end = calendar.nextStartOfMonthForDate(visibleDaysRange.end)
            visibleMonths = DateRange(start: start, end: end)
        }
        return visibleMonths
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        recenterIfNeeded()
        
        if let visibleMonthRange = visibleMonthRange, let visibleMonths = self.visibleMonths, visibleMonthRange != visibleMonths {
            self.visibleMonths = visibleMonths
            // loadEventsIfNeeded()
        }
        
        if let date = dayAtPoint(center) {
            delegate?.calendarView?(self, didShowDate: date)
        }
    }
}
