//
//  YMCalendarView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final public class YMCalendarView: UIView, YMCalendarAppearance {
    
    private lazy var collectionView: UICollectionView = createCollectionView()
    
    private lazy var layout: YMCalendarLayout = {
        let calendarLayout = YMCalendarLayout(scrollDirection: scrollDirection)
        calendarLayout.delegate = self
        return calendarLayout
    }()
    
    public weak var appearance: YMCalendarAppearance?

    public weak var delegate: YMCalendarDelegate?
    
    public weak var dataSource: YMCalendarDataSource?
    
    public var calendar = Calendar.current {
        didSet {
            reload()
        }
    }

    override public var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    private var gradientLayer = CAGradientLayer()
    
    public var gradientColors: [UIColor]? {
        didSet {
            if let colors = gradientColors {
                gradientLayer.colors = colors.map {$0.cgColor}
            } else {
                gradientLayer.colors = nil
            }
        }
    }
    
    public var gradientLocations: [NSNumber]? {
        set {
            gradientLayer.locations = newValue
        }
        get {
            return gradientLayer.locations
        }
    }
    
    public var gradientStartPoint: CGPoint {
        set {
            gradientLayer.startPoint = newValue
        }
        get {
            return gradientLayer.startPoint
        }
    }
    
    public var gradientEndPoint: CGPoint {
        set {
            gradientLayer.endPoint = newValue
        }
        get {
            return gradientLayer.endPoint
        }
    }
    
    public var allowsMultipleSelection: Bool {
        get {
            return collectionView.allowsMultipleSelection
        }
        set {
            collectionView.allowsMultipleSelection = newValue
        }
    }
    
    public var allowsSelection: Bool {
        get {
            return collectionView.allowsSelection
        }
        set {
            collectionView.allowsSelection = newValue
        }
    }
    
    public var isPagingEnabled: Bool {
        get {
            return collectionView.isPagingEnabled
        }
        set {
            collectionView.isPagingEnabled = newValue
        }
    }
    
    public var scrollDirection: YMScrollDirection = .vertical {
        didSet {
            layout.scrollDirection = scrollDirection
            layout.invalidateLayout()
        }
    }
    
    public var decelerationRate: YMDecelerationRate = .normal {
        didSet {
            collectionView.decelerationRate = decelerationRate.value
        }
    }
    
    public var dayLabelHeight: CGFloat = 18 {
        didSet {
            layout.dayHeaderHeight = dayLabelHeight
            collectionView.reloadData()
        }
    }

    public var monthRange: MonthRange? {
        didSet {
            if let range = monthRange {
                startDate = range.start
            } else {
                startDate = monthDate(from: Date())
            }
        }
    }
    
    private var selectedIndexes: [IndexPath] = []
    
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
    
    private var maxStartDate: MonthDate? {
        guard let range = monthRange else {
            return nil
        }
        return max(range.end.add(month: -numberOfLoadedMonths), range.start)
    }
    
    private func dateFrom(monthDate: MonthDate) -> Date {
        return calendar.date(from: monthDate)
    }

    private func monthDate(from date: Date) -> MonthDate {
        return MonthDate(year: calendar.year(date), month: calendar.month(date))
    }
    
    private lazy var startDate = self.monthDate(from: Date())
    
    public var visibleDays: DateRange? {
        guard let index = collectionView.indexPathsForVisibleItems.first else {
            return nil
        }
        let date = dateForDayAtIndexPath(index)
        let start = calendar.startOfMonthForDate(date)
        let end = calendar.endOfMonthForDate(date)
        return DateRange(start: start, end: end)
    }
    
    // selection
    public var selectAnimation: YMSelectAnimation   = .bounce
    
    public var deselectAnimation: YMSelectAnimation = .fade
    
    private var selectedEventDate: Date?
    
    private var selectedEventIndex: Int = 0
    
    private var displayingMonthDate: Date = Date()
    
    // 読み込む月の数
    // 最大9ヶ月分を読み込む
    private var numberOfLoadedMonths: Int {
        if let range = monthRange {
            return min(range.start.monthDiff(with: range.end), 9)
        }
        return 9
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
        backgroundColor = .white
        
        reuseQueue.registerClass(YMEventsRowView.self, forObjectWithReuseIdentifier: "YMEventsRowViewIdentifier")
        
        addSubview(collectionView)
    }
    
    private func createCollectionView() -> UICollectionView {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundView = UIView()
        collectionView.backgroundView?.layer.insertSublayer(gradientLayer, at: 0)
        collectionView.register(YMMonthDayCollectionCell.self,
                                forCellWithReuseIdentifier: YMMonthDayCollectionCell.identifier)
        collectionView.register(YMMonthBackgroundView.self,
                                forSupplementaryViewOfKind: YMMonthBackgroundView.kind,
                                withReuseIdentifier: YMMonthBackgroundView.identifier)
        collectionView.register(YMMonthWeekView.self,
                                forSupplementaryViewOfKind: YMMonthWeekView.kind,
                                withReuseIdentifier: YMMonthWeekView.identifier)
        return collectionView
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        gradientLayer.frame = bounds

        recenterIfNeeded()
    }
}

extension YMCalendarView {
    // MARK: - Utils

    private func dateForDayAtIndexPath(_ indexPath: IndexPath) -> Date {
        var comp   = DateComponents()
        comp.month = indexPath.section
        comp.day   = indexPath.row
        return calendar.date(byAdding: comp, to: dateFrom(monthDate: startDate))!
    }
    
    private func indexPathForDate(_ date: Date) -> IndexPath? {
        if let range = monthRange {
            guard range.contains(monthDate(from: date)) else {
                return nil
            }
        }
        let comps = calendar.dateComponents([.month, .day], from: dateFrom(monthDate: startDate), to: date)
        guard let day = comps.day, let month = comps.month else {
            return nil
        }
        return IndexPath(item: day, section: month)
    }
    
    private func startDayAtMonth(in section: Int) -> Date {
        return dateForDayAtIndexPath(IndexPath(item: 0, section: section))
    }
    
    private func numberOfDaysForMonth(in section: Int) -> Int {
        let startDay = startDayAtMonth(in: section)
        return calendar.numberOfDaysInMonth(date: startDay)
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
    
    private func offsetForMonth(_ monthDate: MonthDate) -> CGFloat {
        let diff = startDate.monthDiff(with: monthDate)
        let size = scrollDirection == .vertical ? bounds.height : bounds.width
        return size * CGFloat(diff)
    }
    
    fileprivate func monthFromOffset(_ offset: CGFloat) -> MonthDate {
        var month = startDate
        if scrollDirection == .vertical {
            let height = bounds.height
            var y = offset > 0 ? height : 0
            
            while y < fabs(offset) {
                month = month.add(month: offset > 0 ? 1 : -1)
                y += height
            }
        } else {
            let width = bounds.width
            var x = offset > 0 ? width : 0
            
            while x < fabs(offset) {
                month = month.add(month: offset > 0 ? 1 : -1)
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
            let attrStr = NSAttributedString(string: str, attributes: [NSAttributedStringKey.font : font])
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
        let month = monthDate(from: date)
        if let range = monthRange, !range.contains(month) {
            return
        }
        
        let offset = offsetForMonth(month)
        if scrollDirection == .vertical {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
        } else {
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }
        
        delegate?.calendarViewDidScroll?(self)
    }
    
    private func adjustStartDateToCenter(date: MonthDate) -> Int {
        let offset = (numberOfLoadedMonths - 1) / 2
        let start = date.add(month: -offset)
        var s = start
        if let range = monthRange, let maxStartDate = maxStartDate {
            // monthRange.start <= start <= maxStartDate
            if start < range.start {
                s = range.start
            } else if start > maxStartDate {
                s = maxStartDate
            }
        }
        let diff = startDate.monthDiff(with: s)
        self.startDate = s
        return diff
    }
    
    private func recenterIfNeeded() {
        if scrollDirection == .vertical {
            let yOffset = max(collectionView.contentOffset.y, 0)
            let contentHeight = collectionView.contentSize.height
            let boundsHeight = collectionView.bounds.height
            
            guard contentHeight > 0 else {
                return
            }
            
            if yOffset < boundsHeight || collectionView.bounds.maxY + boundsHeight > contentHeight {
                let oldStart = startDate
                
                let centerMonth = monthFromOffset(yOffset)
                let monthOffset = adjustStartDateToCenter(date: centerMonth)
                
                if monthOffset != 0 {
                    let y = offsetForMonth(oldStart)
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
            
            guard contentWidth > 0 else {
                return
            }
            
            if xOffset < monthMaxWidth || collectionView.bounds.maxX + monthMaxWidth > contentWidth {
                let oldStart = startDate
                
                let centerMonth = monthFromOffset(xOffset)
                let monthOffset = adjustStartDateToCenter(date: centerMonth)
                
                if monthOffset != 0 {
                    let x = offsetForMonth(oldStart)
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
        return numberOfDaysForMonth(in: section)
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
        cell.dayLabelAlignment = appearance.dayLabelAlignment(in: self)
        cell.dayLabelColor = appearance.calendarViewAppearance(self, dayLabelTextColorAtDate: date)
        cell.dayLabelBackgroundColor = appearance.calendarViewAppearance(self, dayLabelBackgroundColorAtDate: date)
        cell.dayLabelSelectedColor = appearance.calendarViewAppearance(self, dayLabelSelectedTextColorAtDate: date)
        cell.dayLabelSelectedBackgroundColor = appearance.calendarViewAppearance(self, dayLabelSelectedBackgroundColorAtDate: date)
        cell.dayLabelHeight = dayLabelHeight

        // select cells which already selected dates
        if selectedIndexes.contains(indexPath) {
            cell.select(withAnimation: .none)
        }
        return cell
    }
    
    fileprivate func backgroundViewForAtIndexPath(_ indexPath: IndexPath) -> UICollectionReusableView {
        let date = startDayAtMonth(in: indexPath.section)
        
        let lastColumn: Int = columnForDayAtIndexPath(IndexPath(item: 0, section: indexPath.section + 1))
        let numRows: Int = calendar.numberOfWeeksInMonth(date: date)
        
        guard let view = collectionView
            .dequeueReusableSupplementaryView(ofKind: YMMonthBackgroundView.kind,
                                              withReuseIdentifier: YMMonthBackgroundView.identifier,
                                              for: indexPath) as? YMMonthBackgroundView else {
                                                fatalError()
        }
        view.lastColumn = lastColumn
        view.numberOfRows = numRows
        
        let viewAppearance = appearance ?? self
        view.horizontalGridColor = viewAppearance.horizontalGridColor(in: self)
        view.horizontalGridWidth = viewAppearance.horizontalGridWidth(in: self)
        view.verticalGridColor = viewAppearance.verticalGridColor(in: self)
        view.verticalGridWidth = viewAppearance.verticalGridWidth(in: self)
        
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
            let shouldSelect = delegate?.calendarView?(self, shouldSelectEventAtIndex: indexPath.item, date: date) else {
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
            let shouldDeselect = delegate?.calendarView?(self, shouldDeselectEventAtIndex: indexPath.item, date: date) else {
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
        
        delegate?.calendarView?(self, didDeselectEventAtIndex: indexPath.item, date: date)
    }
}

extension YMCalendarView: YMCalendarLayoutDelegate {
    // MARK: - public
    
    /// Select cell item from date manually.
    public func selectDayCell(at date: Date) {
        // select cells
        guard let indexPath = indexPathForDate(date) else { return }
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition(rawValue: 0))
        collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /// Deselect cell item of selecting indexPath manually.
    public func deselectDayCells() {
        // deselect cells
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
    }
    
    // MARK: - YMCalendarLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout: YMCalendarLayout, columnForDayAtIndexPath indexPath: IndexPath) -> Int {
        return columnForDayAtIndexPath(indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    private func cellForItem(at indexPath: IndexPath) -> YMMonthDayCollectionCell? {
        return collectionView.cellForItem(at: indexPath) as? YMMonthDayCollectionCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if allowsMultipleSelection {
            if let i = selectedIndexes.index(of: indexPath) {
                cellForItem(at: indexPath)?.deselect(withAnimation: deselectAnimation)
                selectedIndexes.remove(at: i)
            } else {
                cellForItem(at: indexPath)?.select(withAnimation: selectAnimation)
                selectedIndexes.append(indexPath)
            }
        } else {
            selectedIndexes.forEach {
                cellForItem(at: $0)?.deselect(withAnimation: deselectAnimation)
            }
            cellForItem(at: indexPath)?.select(withAnimation: selectAnimation)
            selectedIndexes = [indexPath]
        }
        
        delegate?.calendarView?(self, didSelectDayCellAtDate: dateForDayAtIndexPath(indexPath))
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        recenterIfNeeded()
        
        if let indexPath = collectionView.indexPathForItem(at: center) {
            let date = dateForDayAtIndexPath(indexPath)
            let startMonth = calendar.startOfMonthForDate(date)
            if displayingMonthDate != startMonth {
                displayingMonthDate = startMonth
                delegate?.calendarView?(self, didMoveMonthOfStartDate: startMonth)
            }
        }
        
        delegate?.calendarViewDidScroll?(self)
    }
}
