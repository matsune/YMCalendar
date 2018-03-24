//
//  YMCalendarLayout.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

private enum AttrKey {
    case dayCells
    case weeks
    case months
}

final class YMCalendarLayout: UICollectionViewLayout {

    typealias AttrDict = [IndexPath : UICollectionViewLayoutAttributes]
    
    var scrollDirection: YMScrollDirection = .horizontal
    
    private var layoutAttrDict: [AttrKey : AttrDict] = [:]
    
    weak var dataSource: YMCalendarLayoutDataSource?
    
    var dayHeaderHeight: CGFloat = 18.0
    
    var contentSize: CGSize = .zero

    fileprivate func widthForColumnRange(_ range: NSRange) -> CGFloat {
        let availableWidth = collectionView?.bounds.size.width ?? 300
        let columnWidth = availableWidth / 7
        
        if NSMaxRange(range) == 7 {
            return availableWidth - columnWidth * CGFloat((7 - range.length))
        }
        return columnWidth * CGFloat(range.length)
    }
    
    fileprivate func columnWidth(colIndex: Int) -> CGFloat {
        return widthForColumnRange(NSRange(location: colIndex, length: 1))
    }
    
    override public func prepare() {
        super.prepare()
        
        contentSize = .zero
        
        guard let collectionView = collectionView else {
            return
        }
        
        let numberOfMonths = collectionView.numberOfSections
        
        var monthsAttrDict: AttrDict = [:]
        var weeksAttrDict: AttrDict = [:]
        var dayCellsAttrDict: AttrDict = [:]
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for month in 0..<numberOfMonths {
            var column = dataSource?.collectionView(collectionView, layout: self, columnAt: IndexPath(item: 0, section: month)) ?? 0
            let numberOfDaysInMonth = collectionView.numberOfItems(inSection: month)
            let numberOfRows = Int(ceil(Double(column + numberOfDaysInMonth) / 7.0))
            let rowHeight = collectionView.bounds.height / CGFloat(numberOfRows)
            var day = 0
            
            var monthRect = CGRect()
            monthRect.origin = CGPoint(x: x, y: y)
            
            for _ in 0..<numberOfRows {
                let colRange = NSMakeRange(column, min(7 - column, numberOfDaysInMonth - day))
                let indexPath = IndexPath(item: day, section: month)
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YMMonthWeekView.ym.kind, with: indexPath)
                let width = widthForColumnRange(NSRange(location: column, length: colRange.length))
                
                if scrollDirection == .vertical {
                    let px = widthForColumnRange(NSRange(location: 0, length: column))
                    attributes.frame = CGRect(x: px, y: y + dayHeaderHeight + 4, width: width, height: rowHeight - dayHeaderHeight - 4)
                } else {
                    let width = widthForColumnRange(NSRange(location: column, length: colRange.length))
                    attributes.frame = CGRect(x: x + widthForColumnRange(NSRange(location: 0, length: column)), y: y + dayHeaderHeight + 4, width: width, height: rowHeight - dayHeaderHeight - 4)
                }
                attributes.zIndex = 1
                weeksAttrDict.updateValue(attributes, forKey: indexPath)

                while column < NSMaxRange(colRange) {
                    let path = IndexPath(item: day, section: month)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: path)
                    
                    let px: CGFloat
                    if scrollDirection == .vertical {
                        px = widthForColumnRange(NSRange(location: 0, length: column))
                    } else {
                        px = widthForColumnRange(NSRange(location: 0, length: column)) + x
                    }
                    
                    let width = widthForColumnRange(NSRange(location: column, length: 1))
                    attributes.frame = CGRect(x: px, y: y, width: width, height: rowHeight)
                    dayCellsAttrDict.updateValue(attributes, forKey: path)
                    
                    column += 1
                    day += 1
                }
                
                y += rowHeight
                column = 0
            }
            
            if scrollDirection == .vertical {
                monthRect.size = CGSize(width: collectionView.bounds.size.width, height: y - monthRect.origin.y)
            } else {
                x += collectionView.bounds.size.width
                y = 0
                
                monthRect.size = CGSize(width: x - monthRect.origin.x, height: collectionView.bounds.height)
            }
            
            let path = IndexPath(item: 0, section: month)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YMMonthBackgroundView.ym.kind, with: path)
            attributes.frame = monthRect
            attributes.zIndex = 0
            monthsAttrDict.updateValue(attributes, forKey: path)
        }
                
        if scrollDirection == .vertical {
            x = collectionView.bounds.width
        } else {
            y = collectionView.bounds.height
        }
        contentSize = CGSize(width: x, height: y)
        
        collectionView.contentInset = .zero
        
        layoutAttrDict.updateValue(dayCellsAttrDict, forKey: .dayCells)
        layoutAttrDict.updateValue(monthsAttrDict, forKey: .months)
        layoutAttrDict.updateValue(weeksAttrDict, forKey: .weeks)
    }
    
    override public var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layout = layoutAttrDict[.dayCells],
            let attr = layout[indexPath] else {
            return nil
        }
        return attr
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        layoutAttrDict.forEach { (kind, attributeDict) in
            attributeDict.forEach { (path, attributes) in
                if rect.intersects(attributes.frame) {
                    allAttributes.append(attributes)
                }
            }
        }
        return allAttributes
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: UICollectionViewLayoutAttributes? = nil
        if elementKind == YMMonthBackgroundView.ym.kind {
            if let layout = layoutAttrDict[.months] {
                attributes = layout[indexPath]
            }
        } else if elementKind == YMMonthWeekView.ym.kind {
            if let layout = layoutAttrDict[.weeks] {
                attributes = layout[indexPath]
            }
        }
        return attributes
    }
}
