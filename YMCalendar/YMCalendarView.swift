//
//  YMCalendarView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public final class YMCalendarView: UIView, YMCalendarAppearance, YMCalendarViewAnimator {
    
    public weak var appearance: YMCalendarAppearance!

    public weak var delegate: YMCalendarDelegate!
    
    public weak var dataSource: YMCalendarDataSource!
    
    public var calendar = Calendar.current
    
    fileprivate var collectionView: UICollectionView!
    
    public var selectionAnimation: YMCalendarSelectionAnimation = .bounce
    
    public var deselectionAnimation: YMCalendarSelectionAnimation = .fade
    
    public var allowsMultipleSelection: Bool {
        get {
            return collectionView.allowsMultipleSelection
        }
        set {
            collectionView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    public var allowsSelection: Bool {
        get {
            return collectionView.allowsSelection
        }
        set {
            collectionView.allowsSelection = allowsSelection
        }
    }
    
    fileprivate var eventRows = ArrayDictionary<Date, YMEventsRowView>()
    
    fileprivate var itemHeight: CGFloat = 16
    
    fileprivate var rowHeight: CGFloat = 140
    
    fileprivate let rowCacheSize = 40
    
    fileprivate var reuseQueue = ReusableObjectQueue()
    
    fileprivate var dateRange: DateRange?
    
    public func setDateRange(_ dateRange: DateRange?) {
        var first = visibleDays?.start
        
        self.dateRange = nil
        if let dateRange = dateRange {
            
            
            let start = calendar.startOfMonthForDate(dateRange.start)
            let end = calendar.startOfMonthForDate(dateRange.end)
            
            let range = DateRange(start: start, end: end)
            
            self.dateRange = range
            
            if !range.includesDateRange(loadedDateRange) {
                self.startDate = range.start
            }
            
            if !range.contains(date: first) {
                first = Date()
                if !range.contains(date: first) {
                    first = range.start
                }
            }
        }
        collectionView.reloadData()
        scrollToDate(first!, animated: false)
    }
    
    public var dayLabelHeight: CGFloat = 18 {
        didSet {
            layout.dayHeaderHeight = dayLabelHeight
            collectionView.reloadData()
        }
    }

    public var layout: YMCalendarLayout {
        set {
            collectionView.collectionViewLayout = newValue
        }
        get {
            return collectionView.collectionViewLayout as! YMCalendarLayout
        }
    }
    
    public var isPagingEnabled: Bool {
        set {
            collectionView.isPagingEnabled = newValue
        }
        get {
            return collectionView.isPagingEnabled
        }
    }
    
    public var decelerationRate: YMDecelerationRate = .normal {
        didSet {
            collectionView.decelerationRate = decelerationRate.value
        }
    }
    
    public var scrollDirection: YMScrollDirection = .vertical {
        didSet {
            let monthLayout = YMCalendarLayout(scrollDirection: scrollDirection)
            monthLayout.delegate = self
            monthLayout.monthInsets = monthInsets
            monthLayout.dayHeaderHeight = dayLabelHeight
            layout = monthLayout
        }
    }
    
    fileprivate var maxStartDate: Date? {
        var date: Date? = nil
        if let dateRange = dateRange {
            var comps = DateComponents()
            comps.month = -numberOfLoadedMonths
            date = calendar.date(byAdding: comps, to: dateRange.end)
            if date?.compare(dateRange.start) == .orderedAscending {
                date = dateRange.start
            }
        }
        return date
    }
    
    fileprivate var startDate: Date {
        didSet {
            let s = calendar.startOfMonthForDate(startDate)
            if startDate != s {
                startDate = s
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
    
    public var monthInsets: UIEdgeInsets = .zero {
        didSet {
            layout.monthInsets = monthInsets
            setNeedsLayout()
        }
    }
    
    fileprivate var selectedEventDate: Date?
    
    fileprivate var selectedEventIndex: Int = 0
    
    fileprivate var showingMonthDate: Date = Date()
    
    fileprivate var monthMinimumHeight: CGFloat {
        guard let numWeeks = calendar.minimumRange(of: .weekOfMonth)?.count else {
            fatalError()
        }
        return CGFloat(numWeeks) * rowHeight + monthInsets.top + monthInsets.bottom
    }
    
    fileprivate var monthMaximumHeight: CGFloat {
        guard let numWeeks = calendar.maximumRange(of: .weekOfMonth)?.count else {
            fatalError()
        }
        return CGFloat(numWeeks) * rowHeight + monthInsets.top + monthInsets.bottom
    }
    
    fileprivate var numberOfLoadedMonths: Int {
        var numMonths = 9
        let minContentHeight = collectionView.bounds.height + 2 * monthMaximumHeight
        let minLoadedMonths = Int(ceil(minContentHeight / monthMinimumHeight))
        numMonths = max(numMonths, minLoadedMonths)
        if let dateRange = dateRange,
            let diff = dateRange.components([.month], forCalendar: calendar).month {
            numMonths = min(numMonths, diff)
        }
        
        return numMonths
    }
    
    public var visibleDays: DateRange? {
        collectionView.layoutIfNeeded()
        var range: DateRange? = nil
        
        let visible = collectionView.indexPathsForVisibleItems.sorted()
        if let firstIdx = visible.first, let lastIdx = visible.last, !visible.isEmpty {
            let first = dateForDayAtIndexPath(firstIdx)
            let last  = dateForDayAtIndexPath(lastIdx)
            
            range = DateRange(start: first, end: calendar.nextStartOfMonthForDate(last))
        }
        return range
    }
    
    fileprivate var loadedDateRange: DateRange {
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
        allowsSelection = true
        allowsMultipleSelection = false
        
        collectionView.register(ReusableIdentifier.Month.DayCell.classType, forCellWithReuseIdentifier: ReusableIdentifier.Month.DayCell.identifier)
        collectionView.register(ReusableIdentifier.Month.BackgroundView.classType, forSupplementaryViewOfKind: ReusableIdentifier.Month.BackgroundView.kind, withReuseIdentifier: ReusableIdentifier.Month.BackgroundView.identifier)
        collectionView.register(ReusableIdentifier.Month.RowView.classType, forSupplementaryViewOfKind: ReusableIdentifier.Month.RowView.kind, withReuseIdentifier: ReusableIdentifier.Month.RowView.identifier)
        
        addSubview(collectionView)
    }
    
    
    // MARK: - UIView
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        collectionView.reloadData()
    }
}

extension YMCalendarView {
    // MARK: - Utils

    fileprivate func dateForDayAtIndexPath(_ indexPath: IndexPath) -> Date {
        var comp   = DateComponents()
        comp.month = indexPath.section
        comp.day   = indexPath.row
        return calendar.date(byAdding: comp, to: startDate)!
    }
    
    fileprivate func indexPathForDate(_ date: Date) -> IndexPath? {
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
    
    fileprivate func indexPathsForDaysInRange(_ range: DateRange) -> [IndexPath] {
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
    
    fileprivate func dateStartingMonthAtIndex(_ month: Int) -> Date {
        return dateForDayAtIndexPath(IndexPath(item: 0, section: month))
    }
    
    fileprivate func numberOfDaysForMonthAtMonth(_ month: Int) -> Int {
        let date = dateStartingMonthAtIndex(month)
        return calendar.numberOfDaysInMonthForDate(date)
    }
    
    fileprivate func columnForDayAtIndexPath(_ indexPath: IndexPath) -> Int {
        let date = dateForDayAtIndexPath(indexPath)
        var weekday = calendar.component(.weekday, from: date)
        weekday = (weekday + 7 - calendar.firstWeekday) % 7
        return weekday
    }
    
    fileprivate func dateRangeForYMEventsRowView(_ rowView: YMEventsRowView) -> DateRange {
        let start = calendar.date(byAdding: .day, value: rowView.daysRange.location, to: rowView.referenceDate)
        let end = calendar.date(byAdding: .day, value: NSMaxRange(rowView.daysRange), to: rowView.referenceDate)
        return DateRange(start: start!, end: end!)
    }
    
    fileprivate func offsetForMonth(date: Date) -> CGFloat {
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
    
    fileprivate func heightForMonthAtDate(_ date: Date) -> CGFloat {
        let monthStart = calendar.startOfMonthForDate(date)
        guard let numWeeks = calendar.range(of: .weekOfMonth, in: .month, for: monthStart)?.count else {
            fatalError()
        }
        return CGFloat(numWeeks) * rowHeight + monthInsets.top + monthInsets.bottom
    }
    
    fileprivate func monthFromOffset(_ offset: CGFloat) -> Date {
        var month = startDate
        if scrollDirection == .vertical {
            let height = heightForMonthAtDate(month)
            var y = offset > 0 ? height : 0
            
            while y < fabs(offset) {
                month = calendar.date(byAdding: .month, value: offset > 0 ? 1 : -1, to: month)!
                y += height
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
    
    fileprivate func reload() {
        deselectEventWithDelegate(true)
        
        clearRowsCacheInDateRange(nil)
        collectionView.reloadData()
    }
    
    fileprivate func maxSizeForFont(_ font: UIFont, toFitStrings strings: [String], inSize size: CGSize) -> CGFloat {
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
    
    public func registerClass(_ objectClass: ReusableObject.Type, forEventCellReuseIdentifier identifier: String) {
        reuseQueue.registerClass(objectClass, forObjectWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCellWithIdentifier<T: YMEventView>(_ identifier: String, forEventAtIndex index: Int, date: Date) -> T? {
        let cell: T? = reuseQueue.dequeueReusableObjectWithIdentifier(identifier)
        if let selectedDate = selectedEventDate, calendar.isDate(selectedDate, inSameDayAs: date) && index == selectedEventIndex {
            cell?.selected = true
        }
        return cell
    }
    
    public func reloadEvents() {
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
    
    public func reloadEventsAtDate(_ date: Date) {
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
    
    public func reloadEventsInRange(_ range: DateRange) {
        if let selectedEventDate = selectedEventDate, range.contains(date: selectedEventDate) {
            deselectEventWithDelegate(true)
        }
        if let visibleDateRange = visibleDays {
            var reloadRowViews: [YMEventsRowView] = []
            eventRows.forEach({ date, rowView in
                let rowRange = dateRangeForYMEventsRowView(rowView)
                if rowRange.intersectsDateRange(range) {
                    if rowRange.intersectsDateRange(visibleDateRange) {
                        reloadRowViews.append(rowView)
                    } else {
                        removeRowAtDate(date)
                    }
                }
            })
            DispatchQueue.main.async {
                reloadRowViews.forEach {$0.reload()}
            }
        }
    }
    
    public var visibleEventCells: [YMEventView] {
        var cells: [YMEventView] = []
        for rowView in visibleEventRows {
            let rect = rowView.convert(bounds, from: self)
            cells.append(contentsOf: rowView.cellsInRect(rect))
        }
        return cells
    }
    
    public func cellForEventAtIndex(_ index: Int, date: Date) -> YMEventView? {
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
    
    public func eventCellAtPoint(_ pt: CGPoint, date: inout Date, index: inout Int) -> YMEventView? {
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
    
    public func dayAtPoint(_ point: CGPoint) -> Date? {
        let pt = collectionView.convert(point, from: self)
        if let indexPath = collectionView.indexPathForItem(at: pt) {
            return dateForDayAtIndexPath(indexPath)
        }
        return nil
    }
}

extension YMCalendarView {
    // MARK: - Selection
    
    public var selectedEventView: YMEventView? {
        if let date = selectedEventDate {
            return cellForEventAtIndex(selectedEventIndex, date: date)
        }
        return nil
    }
    
    public func deselectEventWithDelegate(_ tellDelegate: Bool) {
        if let selectedDate = selectedEventDate {
            let cell = cellForEventAtIndex(selectedEventIndex, date: selectedDate)
            cell?.selected = false
            
            if tellDelegate {
                delegate?.calendarView?(self, didDeselectEventAtIndex: selectedEventIndex, date: selectedDate)
            }
            
            selectedEventDate = nil
        }
    }
    
    public func deselectEvent() {
        if allowsSelection {
            deselectEventWithDelegate(false)
        }
    }
    
    public func selectEventCellAtIndex(_ index: Int, date: Date) {
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
    
    public func scrollToDate(_ date: Date, animated: Bool) {
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
    
    fileprivate func adjustStartDateForCenteredMonth(date: Date) -> Int {
        let offset: Int
        if scrollDirection == .vertical {
            let contentHeight = collectionView.contentSize.height
            let boundsHeight = collectionView.bounds.height
            offset = Int(floor((contentHeight - boundsHeight) / monthMaximumHeight) / 2)
        } else {
            let contentWidth = collectionView.contentSize.width
            let boundsWidth = collectionView.bounds.width
            offset = Int(floor((contentWidth - boundsWidth) / collectionView.bounds.width) / 2)
        }
        
        guard let start = calendar.date(byAdding: .month, value: -offset, to: date) else {
            fatalError()
        }
        var s = start
        if let dateRange = dateRange, let maxStartDate = maxStartDate {
            if start.compare(dateRange.start) == .orderedAscending {
                s = dateRange.start
            } else if start.compare(maxStartDate) == .orderedDescending {
                s = maxStartDate
            }
        }
        
        guard let diff = calendar.dateComponents([.month], from: startDate, to: s).month else {
                fatalError()
        }
        
        self.startDate = s
        return diff
    }
    
    func recenterIfNeeded() {
        if scrollDirection == .vertical {
            let yOffset = collectionView.contentOffset.y
            let contentHeight = collectionView.contentSize.height
            
            if yOffset < monthMaximumHeight || collectionView.bounds.maxY + monthMaximumHeight > contentHeight {
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
    fileprivate var visibleEventRows: [YMEventsRowView] {
        var rows: [YMEventsRowView] = []
        if let visibleRange = visibleDays {
            eventRows.forEach({ date, rowView in
                if visibleRange.contains(date: date) {
                    rows.append(rowView)
                }
            })
        }
        return rows
    }
    
    fileprivate func clearRowsCacheInDateRange(_ range: DateRange?) {
        if let range = range {
            eventRows.forEach({ date, rowView in
                if range.contains(date: date) {
                    removeRowAtDate(date)
                }
            })
        } else {
            eventRows.forEach({ date, rowView in
                removeRowAtDate(date)
            })
        }
    }
    
    fileprivate func removeRowAtDate(_ date: Date) {
        if let remove = eventRows.value(forKey: date) {
            reuseQueue.enqueueReusableObject(remove)
            eventRows.removeValue(forKey: date)
        }
    }
    
    fileprivate func eventsRowViewAtDate(_ rowStart: Date) -> YMEventsRowView {
        var eventsRowView: YMEventsRowView? = eventRows.value(forKey: rowStart)
        if eventsRowView == nil {
            eventsRowView = reuseQueue.dequeueReusableObjectWithIdentifier(ReusableIdentifier.Events.rowView.identifier)
            let referenceDate = calendar.startOfMonthForDate(rowStart)
            let first = calendar.dateComponents([.day], from: referenceDate, to: rowStart).day
            if let range = calendar.range(of: .day, in: .weekOfMonth, for: rowStart) {
                let numDays = range.upperBound - range.lowerBound
                
                eventsRowView?.referenceDate = referenceDate
                eventsRowView?.isScrollEnabled = false
                eventsRowView?.itemHeight = itemHeight
                eventsRowView?.eventsRowDelegate = self
                eventsRowView?.daysRange = NSMakeRange(first!, numDays)
                eventsRowView?.dayWidth = bounds.width / 7
                
                eventsRowView?.reload()
            }
        }
        
        cacheRow(eventsRowView!, forDate: rowStart)
        
        return eventsRowView!
    }
    
    fileprivate func cacheRow(_ eventsView: YMEventsRowView, forDate date: Date) {
        if let _ = eventRows.value(forKey: date) {
            eventRows.removeValue(forKey: date)
        }
        eventRows.setValue(eventsView, forKey: date)
        
        if eventRows.count >= rowCacheSize {
            if let first = eventRows.first?.0 {
                removeRowAtDate(first)
            }
        }
    }
    
    fileprivate func monthRowViewAtIndexPath(_ indexPath: IndexPath) -> YMMonthWeekView {
        let rowStart = dateForDayAtIndexPath(indexPath)
        var rowView: YMMonthWeekView?
        var dequeued: Bool = false
        while !dequeued {
            guard let weekView = collectionView.dequeueReusableSupplementaryView(ofKind: ReusableIdentifier.Month.RowView.kind, withReuseIdentifier: ReusableIdentifier.Month.RowView.identifier, for: indexPath) as? YMMonthWeekView else {
                fatalError()
            }
            rowView = weekView
            if !visibleEventRows.contains(rowView!.eventsView) {
                dequeued = true
            }
        }
        
        let eventsView = eventsRowViewAtDate(rowStart)
        
        rowView!.eventsView = eventsView
        return rowView!
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
        let appearance = self.appearance ?? self
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableIdentifier.Month.DayCell.identifier, for: indexPath) as? YMMonthDayCollectionCell else {
            fatalError()
        }
        let date = dateForDayAtIndexPath(indexPath)
        let font = appearance.calendarViewAppearance(self, dayLabelFontAtDate: date)
        cell.day = calendar.day(date)
        cell.dayLabel.font = font
        cell.dayLabelColor = appearance.calendarViewAppearance(self, dayLabelTextColorAtDate: date)
        cell.dayLabelBackgroundColor = appearance.calendarViewAppearance(self, dayLabelBackgroundColorAtDate: date)
        cell.dayLabelSelectionColor = appearance.calendarViewAppearance(self, dayLabelSelectionTextColorAtDate: date)
        cell.dayLabelSelectionBackgroundColor = appearance.calendarViewAppearance(self, dayLabelSelectionBackgroundColorAtDate: date)
        cell.dayLabelHeight = dayLabelHeight
        return cell
    }
    
    fileprivate func backgroundViewForAtIndexPath(_ indexPath: IndexPath) -> UICollectionReusableView {
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
            return monthRowViewAtIndexPath(indexPath)
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
    
    func eventsRowView(_ view: YMEventsRowView, shouldSelectCellAtIndexPath indexPath: IndexPath) -> Bool {
        if !allowsSelection {
            return false
        }
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate),
            let shouldSelect = delegate.calendarView?(self, shouldSelectEventAtIndex: indexPath.item, date: date) else {
            return true
        }
        return shouldSelect
    }
    
    func eventsRowView(_ view: YMEventsRowView, didSelectCellAtIndexPath indexPath: IndexPath) {
        deselectEventWithDelegate(true)
        
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate) else {
            return
        }
        
        selectedEventDate = date
        selectedEventIndex = indexPath.item
        
        delegate?.calendarView?(self, didSelectEventAtIndex: indexPath.item, date: date)
    }
    
    func eventsRowView(_ view: YMEventsRowView, shouldDeselectCellAtIndexPath indexPath: IndexPath) -> Bool {
        if !allowsSelection {
            return false
        }
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate),
            let shouldDeselect = delegate.calendarView?(self, shouldDeselectEventAtIndex: indexPath.item, date: date) else {
                return true
        }
        return shouldDeselect
    }
    
    func eventsRowView(_ view: YMEventsRowView, didDeselectCellAtIndexPath indexPath: IndexPath) {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate) else {
            return
        }
        if selectedEventDate == date && indexPath.item == selectedEventIndex {
            selectedEventDate = nil
            selectedEventIndex = 0
        }
        
        delegate.calendarView?(self, didDeselectEventAtIndex: indexPath.item, date: date)
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
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? YMMonthDayCollectionCell {
            animateSelectionDayCell(selectedCell)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let deselectedCell = collectionView.cellForItem(at: indexPath) as? YMMonthDayCollectionCell {
            animateDeselectionDayCell(deselectedCell)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        recenterIfNeeded()
        
        if let date = dayAtPoint(center) {
            delegate?.calendarView?(self, didShowDate: date)
            
            let startMonth = calendar.startOfMonthForDate(date)
            if showingMonthDate != startMonth {
                showingMonthDate = startMonth
                delegate?.calendarView?(self, didMoveMonthOfStartDate: startMonth)
            }
        }
        
        delegate?.calendarViewDidScroll?(self)
    }
}
