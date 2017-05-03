//
//  YMCalendarView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final public class YMCalendarView: UIView, YMCalendarAppearance, YMCalendarViewAnimator {
    
    fileprivate var collectionView: UICollectionView!
    
    public weak var appearance: YMCalendarAppearance!

    public weak var delegate: YMCalendarDelegate!
    
    public weak var dataSource: YMCalendarDataSource!
    
    public var calendar = Calendar.current
    
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
    
    /// Height of event items in EventsRow. Default value is 16.
    public var eventViewHeight: CGFloat = 16
    
    /// Number of visble events in a week row.
    /// If value is nil, events can be displayed by scroll.
    public var maxVisibleEvents: Int?
    
    /// Cache of EventsRowViews. EventsRowView belongs to MonthWeekView and
    /// has events(YMEventViews) for a week. This dictionary has start of week
    /// as key and events as value.
    fileprivate var eventRowsCache = IndexableDictionary<Date, YMEventsRowView>()
    
    /// Capacity of eventRowsCache.
    fileprivate let rowCacheSize = 40
    
    /// Manager of registered class and identifiers.
    fileprivate var reuseQueue = ReusableObjectQueue()
    
    fileprivate var dateRange: DateRange?
    
    /// Set date range of CalendarView. If you set nil, calendar will be infinite.
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

    fileprivate var layout: YMCalendarLayout {
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
    
    fileprivate var startDate = Date() {
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
    
    public var selectedDate: Date?
    
    fileprivate var selectedEventDate: Date?
    
    fileprivate lazy var selectedEventIndex: Int = {
        return 0
    }()
    
    fileprivate lazy var showingMonthDate: Date = {
        return Date()
    }()
    
    fileprivate var numberOfLoadedMonths: Int {
        if let dateRange = dateRange,
            let diff = calendar.dateComponents([.month], from: dateRange.start, to: dateRange.end).month {
            return min(diff, 9)
        }
        return 9
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
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        startDate = calendar.startOfMonthForDate(Date())
        
        reuseQueue.registerClass(YMEventsRowView.self, forObjectWithReuseIdentifier: "YMEventsRowViewIdentifier")

        let monthLayout = YMCalendarLayout(scrollDirection: scrollDirection)
        monthLayout.delegate = self
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: monthLayout)
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        allowsSelection = true
        allowsMultipleSelection = false
        
        // Register ReusableCell
        collectionView.register(YMMonthDayCollectionCell.self, forCellWithReuseIdentifier: YMMonthDayCollectionCell.identifier)
        // Register ReusableSupplementaryView
        collectionView.register(YMMonthBackgroundView.self, forSupplementaryViewOfKind: YMMonthBackgroundView.kind, withReuseIdentifier: YMMonthBackgroundView.identifier)
        collectionView.register(YMMonthWeekView.self, forSupplementaryViewOfKind: YMMonthWeekView.kind, withReuseIdentifier: YMMonthWeekView.identifier)
        
        addSubview(collectionView)
        
        backgroundColor = .white
    }
    
    
    // MARK: - UIView
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()
        recenterIfNeeded()
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
    
    fileprivate func monthFromOffset(_ offset: CGFloat) -> Date {
        var month = startDate
        if scrollDirection == .vertical {
            let height = bounds.height
            var y = offset > 0 ? height : 0
            
            while y < fabs(offset) {
                month = calendar.date(byAdding: .month, value: offset > 0 ? 1 : -1, to: month)!
                y += height
            }
        } else {
            let width = collectionView.bounds.width
            var x = offset > 0 ? width : 0
            
            while x < fabs(offset) {
                month = calendar.date(byAdding: .month, value: offset > 0 ? 1 : -1, to: month)!
                x += width
            }
        }
        return month
    }
    
    public func reload() {
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
        guard let cell = reuseQueue.dequeueReusableObjectWithIdentifier(identifier) as? T? else {
            return nil
        }
        if let selectedDate = selectedEventDate,
            calendar.isDate(selectedDate, inSameDayAs: date) && index == selectedEventIndex {
            cell?.selected = true
        }
        return cell
    }
    
    public func reloadEvents() {
        deselectEventWithDelegate(true)
        guard let visibleDateRange = visibleDays else {
            return
        }
        eventRowsCache.forEach { date, rowView in
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
            eventRowsCache.forEach { date, rowView in
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
            eventRowsCache.forEach({ date, rowView in
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
    
    public func eventViewForEventAtIndex(_ index: Int, date: Date) -> YMEventView? {
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
            return eventViewForEventAtIndex(selectedEventIndex, date: date)
        }
        return nil
    }
    
    public func deselectEventWithDelegate(_ tellDelegate: Bool) {
        if let selectedDate = selectedEventDate {
            let cell = eventViewForEventAtIndex(selectedEventIndex, date: selectedDate)
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
            let cell = eventViewForEventAtIndex(index, date: date)
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
        
        let offset = offsetForMonth(date: date)
        if scrollDirection == .vertical {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
        } else {
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }
        
        delegate?.calendarViewDidScroll?(self)
    }
    
    fileprivate func adjustStartDateForCenteredMonth(date: Date) -> Int {
        let offset: Int
        if scrollDirection == .vertical {
            let contentHeight = collectionView.contentSize.height
            let boundsHeight = collectionView.bounds.height
            offset = Int(floor((contentHeight - boundsHeight) / boundsHeight) / 2)
        } else {
            let contentWidth = collectionView.contentSize.width
            let boundsWidth = collectionView.bounds.width
            offset = Int(floor((contentWidth - boundsWidth) / boundsWidth) / 2)
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
            let yOffset = max(collectionView.contentOffset.y, 0)
            let contentHeight = collectionView.contentSize.height
            let boundsHeight = collectionView.bounds.height
            
            if yOffset < boundsHeight || collectionView.bounds.maxY + boundsHeight > contentHeight {
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
            let xOffset = max(collectionView.contentOffset.x, 0)
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
            eventRowsCache.forEach({ date, rowView in
                if visibleRange.contains(date: date) {
                    rows.append(rowView)
                }
            })
        }
        return rows
    }
    
    fileprivate func clearRowsCacheInDateRange(_ range: DateRange?) {
        if let range = range {
            eventRowsCache.forEach({ date, rowView in
                if range.contains(date: date) {
                    removeRowAtDate(date)
                }
            })
        } else {
            eventRowsCache.forEach({ date, rowView in
                removeRowAtDate(date)
            })
        }
    }
    
    fileprivate func removeRowAtDate(_ date: Date) {
        if let remove = eventRowsCache.removeValue(forKey: date) {
            reuseQueue.enqueueReusableObject(remove)
        }
    }
    
    fileprivate func eventsRowViewAtDate(_ rowStart: Date) -> YMEventsRowView {
        var eventsRowView = eventRowsCache.value(forKey: rowStart)
        if eventsRowView == nil {
            eventsRowView = reuseQueue.dequeueReusableObjectWithIdentifier("YMEventsRowViewIdentifier") as! YMEventsRowView?
            let referenceDate = calendar.startOfMonthForDate(rowStart)
            let first = calendar.dateComponents([.day], from: referenceDate, to: rowStart).day
            if let range = calendar.range(of: .day, in: .weekOfMonth, for: rowStart) {
                let numDays = range.upperBound - range.lowerBound
                
                eventsRowView?.referenceDate = referenceDate
                eventsRowView?.maxVisibleLines = maxVisibleEvents
                eventsRowView?.itemHeight = eventViewHeight
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
        eventRowsCache.updateValue(eventsView, forKey: date)
        
        if eventRowsCache.count >= rowCacheSize {
            if let first = eventRowsCache.first?.0 {
                removeRowAtDate(first)
            }
        }
    }
    
    fileprivate func monthRowViewAtIndexPath(_ indexPath: IndexPath) -> YMMonthWeekView {
        let rowStart = dateForDayAtIndexPath(indexPath)
        var rowView: YMMonthWeekView!
        var dequeued: Bool = false
        while !dequeued {
            guard let weekView = collectionView.dequeueReusableSupplementaryView(ofKind: YMMonthWeekView.kind, withReuseIdentifier: YMMonthWeekView.identifier, for: indexPath) as? YMMonthWeekView else {
                fatalError()
            }
            rowView = weekView
            if !visibleEventRows.contains(rowView.eventsView) {
                dequeued = true
            }
        }
        
        let eventsView = eventsRowViewAtDate(rowStart)
        
        rowView.eventsView = eventsView
        return rowView!
    }
}

extension YMCalendarView: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfLoadedMonths
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDaysForMonthAtMonth(section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let appearance = self.appearance ?? self
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YMMonthDayCollectionCell.identifier, for: indexPath) as? YMMonthDayCollectionCell else {
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
        if date == selectedDate {
            cell.animateSelection(with: .none)
        }
        return cell
    }
    
    fileprivate func backgroundViewForAtIndexPath(_ indexPath: IndexPath) -> UICollectionReusableView {
        let date = dateStartingMonthAtIndex(indexPath.section)
        
        let lastColumn: Int = columnForDayAtIndexPath(IndexPath(item: 0, section: indexPath.section + 1))
        let numRows: Int = calendar.numberOfWeeksInMonthForDate(date)
        
        guard let view = collectionView
            .dequeueReusableSupplementaryView(ofKind: YMMonthBackgroundView.kind,
                                              withReuseIdentifier: YMMonthBackgroundView.identifier,
                                              for: indexPath) as? YMMonthBackgroundView else {
                                                fatalError()
        }
        view.setAppearance(appearance ?? self, numberOfColumns: 7, numberOfRows: numRows, lastColumn: lastColumn)
        view.setNeedsDisplay()
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case YMMonthBackgroundView.kind:
            return backgroundViewForAtIndexPath(indexPath)
        case YMMonthWeekView.kind:
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
    
    func eventsRowView(_ view: YMEventsRowView, cellForEventAtIndexPath indexPath: IndexPath) -> YMEventView  {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.referenceDate),
            let eventView = dataSource?.calendarView(self, eventViewForEventAtIndex: indexPath.item, date: date) else {
            fatalError()
        }
        return eventView
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
        selectedDate = date
        delegate?.calendarView?(self, didSelectDayCellAtDate: date)
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? YMMonthDayCollectionCell {
            animateSelectionDayCell(selectedCell)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedDate = nil
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
