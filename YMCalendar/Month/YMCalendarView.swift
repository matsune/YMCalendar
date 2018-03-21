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
    /// has events(UIViews) for a week. This dictionary has start of week
    /// as key and events as value.
    fileprivate var eventRowsCache = IndexableDictionary<Date, YMEventsRowView>()
    
    /// Capacity of eventRowsCache.
    fileprivate let rowCacheSize = 40
    
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
        return calendar.monthDate(from: date)
    }
    
    private lazy var startDate = self.monthDate(from: Date())
    
    public var visibleMonths: [MonthDate] {
        var res: [MonthDate] = []
        if let first = collectionView.indexPathsForVisibleItems.first {
            res.append(monthDate(from: dateAt(first)))
        }
        if let last = collectionView.indexPathsForVisibleItems.last {
            let month = monthDate(from: dateAt(last))
            if !res.contains(month) {
                res.append(month)
            }
        }
        return res
    }
    
    public var visibleDays: DateRange? {
        guard let first = collectionView.indexPathsForVisibleItems.first,
            let last = collectionView.indexPathsForVisibleItems.last else {
            return nil
        }
        return DateRange(start: dateAt(first), end: dateAt(last))
    }
    
    // selection
    public var selectAnimation: YMSelectAnimation = .bounce
    
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
        collectionView.ym.register(YMMonthDayCollectionCell.self)
        collectionView.ym.register(YMMonthBackgroundView.self)
        collectionView.ym.register(YMMonthWeekView.self)
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

    private func dateAt(_ indexPath: IndexPath) -> Date {
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
        return dateAt(IndexPath(item: 0, section: section))
    }
    
    private func column(at indexPath: IndexPath) -> Int {
        var weekday = calendar.component(.weekday, from: dateAt(indexPath))
        weekday = (weekday + 7 - calendar.firstWeekday) % 7
        return weekday
    }
    
    private func dateRangeOf(rowView: YMEventsRowView) -> DateRange? {
        guard let start = calendar.date(byAdding: .day, value: rowView.daysRange.location, to: rowView.monthStart),
            let end = calendar.date(byAdding: .day, value: NSMaxRange(rowView.daysRange), to: rowView.monthStart) else {
                return nil
        }
        return DateRange(start: start, end: end)
    }
    
    public func reload() {
        clearRowsCacheIn(range: nil)
        collectionView.reloadData()
    }
}

extension YMCalendarView {
    
    // MARK: - Public
    
    public func reloadEvents() {
        eventRowsCache.forEach {
            $0.value.reload()
        }
    }
    
    public func reloadEventsAtDate(_ date: Date) {
        eventRowsCache.first(where: { $0.key == date })?.value.reload()
    }
    
    public func reloadEventsInRange(_ range: DateRange) {
        eventRowsCache
            .filter {
                dateRangeOf(rowView: $0.value)?.intersectsDateRange(range) ?? false
            }.forEach {
                $0.value.reload()
            }
    }
    
    public func reloadEvents(in monthDate: MonthDate) {
        eventRowsCache
            .filter { self.monthDate(from: $0.key) == monthDate }
            .forEach { $0.value.reload() }
    }
    
    public var visibleEventViews: [UIView] {
        return visibleEventRows.flatMap {
            $0.viewsInRect($0.convert(bounds, to: self))
        }
    }
    
    public func eventViewForEventAtIndex(_ index: Int, date: Date) -> UIView? {
        for rowView in visibleEventRows {
            guard let day = calendar.dateComponents([.day], from: rowView.monthStart, to: date).day else {
                return nil
            }
            if NSLocationInRange(day, rowView.daysRange) {
                return rowView.eventView(at: IndexPath(item: index, section: day))
            }
        }
        return nil
    }
    
    public func eventCellAtPoint(_ pt: CGPoint, date: inout Date, index: inout Int) -> UIView? {
        for rowView in visibleEventRows {
            let ptInRow = rowView.convert(pt, from: self)
            if let path = rowView.indexPathForCellAtPoint(ptInRow) {
                var comps = DateComponents()
                comps.day = path.section
                date = calendar.date(byAdding: comps, to: rowView.monthStart)!
                index = path.item
                return rowView.eventView(at: path)
            }
        }
        return nil
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
    
    private func offsetForMonth(_ monthDate: MonthDate) -> CGFloat {
        let diff = startDate.monthDiff(with: monthDate)
        let size = scrollDirection == .vertical ? bounds.height : bounds.width
        return size * CGFloat(diff)
    }
    
    private func monthFromOffset(_ offset: CGFloat) -> MonthDate {
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
        let offset, content, bounds, boundsMax: CGFloat
        switch scrollDirection {
        case .vertical:
            offset = max(collectionView.contentOffset.y, 0)
            content = collectionView.contentSize.height
            bounds = collectionView.bounds.height
            boundsMax = collectionView.bounds.maxY
        case .horizontal:
            offset = max(collectionView.contentOffset.x, 0)
            content = collectionView.contentSize.width
            bounds = collectionView.bounds.width
            boundsMax = collectionView.bounds.maxX
        }
        
        guard content > 0 else {
            return
        }
        
        if offset < bounds || boundsMax + bounds > content {
            let oldStart = startDate
            
            let centerMonth = monthFromOffset(offset)
            let monthOffset = adjustStartDateToCenter(date: centerMonth)
            
            if monthOffset != 0 {
                let k = offsetForMonth(oldStart)
                collectionView.reloadData()
                
                var contentOffset = collectionView.contentOffset
                switch scrollDirection {
                case .vertical:
                    contentOffset.y = k + offset
                case .horizontal:
                    contentOffset.x = k + offset
                }
                collectionView.contentOffset = contentOffset
            }
        }
    }
}

extension YMCalendarView {
    // MARK: - Rows Handling
    
    private func removeRowCache(at date: Date) {
        eventRowsCache.removeValue(forKey: date)
    }
    
    private var visibleEventRows: [YMEventsRowView] {
        guard let visibleRange = visibleDays else {
            return []
        }
        return eventRowsCache
            .filter {
                visibleRange.contains(date: $0.key)
            }.map {
                $0.value
            }
    }
    
    private func clearRowsCacheIn(range: DateRange?) {
        if let range = range {
            eventRowsCache
                .filter { range.contains(date: $0.key) }
                .forEach { removeRowCache(at: $0.key) }
        } else {
            eventRowsCache.forEach { removeRowCache(at: $0.key) }
        }
    }
    
    private func eventsRowView(at rowStart: Date) -> YMEventsRowView {
        var eventsRowView = eventRowsCache.value(forKey: rowStart)
        if eventsRowView == nil {
            eventsRowView = YMEventsRowView()
            let startOfMonth = calendar.startOfMonthForDate(rowStart)
            let first = calendar.dateComponents([.day], from: startOfMonth, to: rowStart).day
            if let range = calendar.range(of: .day, in: .weekOfMonth, for: rowStart) {
                let numDays = range.upperBound - range.lowerBound

                eventsRowView?.monthStart = startOfMonth
                eventsRowView?.maxVisibleLines = maxVisibleEvents
                eventsRowView?.itemHeight = eventViewHeight
                eventsRowView?.eventsRowDelegate = self
                eventsRowView?.daysRange = NSMakeRange(first!, numDays)
                eventsRowView?.dayWidth = bounds.width / 7
                
                eventsRowView?.reload()
            }
            cacheRow(eventsRowView!, forDate: rowStart)
        }
        return eventsRowView!
    }
    
    private func cacheRow(_ eventsView: YMEventsRowView, forDate date: Date) {
        eventRowsCache.updateValue(eventsView, forKey: date)
        
        if eventRowsCache.count >= rowCacheSize {
            if let first = eventRowsCache.first?.0 {
                removeRowCache(at: first)
            }
        }
    }
    
    private func monthRowView(at indexPath: IndexPath) -> YMMonthWeekView {
        var weekView: YMMonthWeekView!
        while true {
            let v = collectionView.ym.dequeue(YMMonthWeekView.self, for: indexPath)
            if !visibleEventRows.contains(v.eventsView) {
                weekView = v
                break
            }
        }
        
        weekView.eventsView = eventsRowView(at: dateAt(indexPath))
        return weekView
    }
}

extension YMCalendarView: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfLoadedMonths
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let startDay = startDayAtMonth(in: section)
        return calendar.numberOfDaysInMonth(date: startDay)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let appearance = self.appearance ?? self
        
        let cell = collectionView.ym.dequeue(YMMonthDayCollectionCell.self, for: indexPath)
        let date = dateAt(indexPath)
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
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case YMMonthBackgroundView.ym.kind:
            return backgroundView(at: indexPath)
        case YMMonthWeekView.ym.kind:
            return monthRowView(at: indexPath)
        default:
            fatalError()
        }
    }
    
    private func backgroundView(at indexPath: IndexPath) -> UICollectionReusableView {
        let date = startDayAtMonth(in: indexPath.section)
        
        let lastColumn = column(at: IndexPath(item: 0, section: indexPath.section + 1))
        let numRows = calendar.numberOfWeeksInMonth(date: date)
        
        let view = collectionView.ym.dequeue(YMMonthBackgroundView.self, for: indexPath)
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
}

extension YMCalendarView: YMEventsRowViewDelegate {
    // MARK: - YMEventsRowViewDelegate
    
    func eventsRowView(_ view: YMEventsRowView, numberOfEventsAt day: Int) -> Int {
        var comps = DateComponents()
        comps.day = day
        guard let date = calendar.date(byAdding: comps, to: view.monthStart),
            let count = dataSource?.calendarView(self, numberOfEventsAtDate: date) else {
            return 0
        }
        return count
    }
    
    func eventsRowView(_ view: YMEventsRowView, rangeForEventAtIndexPath indexPath: IndexPath) -> NSRange {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.monthStart),
            let dateRange = dataSource?.calendarView(self, dateRangeForEventAtIndex: indexPath.item, date: date) else {
            return NSRange()
        }
        
        let start = max(0, calendar.dateComponents([.day], from: view.monthStart, to: dateRange.start).day!)
        var end = calendar.dateComponents([.day], from: view.monthStart, to: dateRange.end).day!
        if dateRange.end.timeIntervalSince(calendar.startOfDay(for: dateRange.end)) >= 0 {
            end += 1
        }
        end = min(end, NSMaxRange(view.daysRange))
        return NSMakeRange(start, end - start)
    }
    
    private var defaultStyle: Style<UIView> {
        return Style<UIView> {
            $0.backgroundColor = .orange
        }
    }
    
    func eventsRowView(_ view: YMEventsRowView, styleForEventViewAt indexPath: IndexPath) -> Style<UIView> {
        var comp = DateComponents()
        comp.day = indexPath.section
        guard let date = calendar.date(byAdding: comp, to: view.monthStart) else {
            return defaultStyle
        }
        return dataSource?.calendarView(self, styleForEventViewAt: indexPath.item, date: date) ?? defaultStyle
    }
    
    func eventsRowView(_ view: YMEventsRowView, shouldSelectCellAtIndexPath indexPath: IndexPath) -> Bool {
        if !allowsSelection {
            return false
        }
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.monthStart),
            let shouldSelect = delegate?.calendarView?(self, shouldSelectEventAtIndex: indexPath.item, date: date) else {
            return true
        }
        return shouldSelect
    }
    
    func eventsRowView(_ view: YMEventsRowView, shouldDeselectCellAtIndexPath indexPath: IndexPath) -> Bool {
        if !allowsSelection {
            return false
        }
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.monthStart),
            let shouldDeselect = delegate?.calendarView?(self, shouldDeselectEventAtIndex: indexPath.item, date: date) else {
                return true
        }
        return shouldDeselect
    }
    
    func eventsRowView(_ view: YMEventsRowView, didSelectCellAtIndexPath indexPath: IndexPath) {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.monthStart) else {
            return
        }
        
        selectedEventDate = date
        selectedEventIndex = indexPath.item
        
        delegate?.calendarView?(self, didSelectEventAtIndex: indexPath.item, date: date)
    }
    
    func eventsRowView(_ view: YMEventsRowView, didDeselectCellAtIndexPath indexPath: IndexPath) {
        var comps = DateComponents()
        comps.day = indexPath.section
        guard let date = calendar.date(byAdding: comps, to: view.monthStart) else {
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
        return column(at: indexPath)
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
        
        delegate?.calendarView?(self, didSelectDayCellAtDate: dateAt(indexPath))
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        recenterIfNeeded()
        
        if let indexPath = collectionView.indexPathForItem(at: center) {
            let date = dateAt(indexPath)
            let startMonth = calendar.startOfMonthForDate(date)
            if displayingMonthDate != startMonth {
                displayingMonthDate = startMonth
                delegate?.calendarView?(self, didMoveMonthOfStartDate: startMonth)
            }
        }
        
        delegate?.calendarViewDidScroll?(self)
    }
}
