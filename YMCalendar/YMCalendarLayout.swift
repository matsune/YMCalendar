//
//  YMCalendarLayout.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final class YMCalendarLayout: UICollectionViewLayout {

    typealias AttrDict = [IndexPath : UICollectionViewLayoutAttributes]
    
    private var scrollDirection: YMScrollDirection
    
    var layoutAttrDict: [String : AttrDict] = [:]
    var isShowEvents = true
    var monthInsets: UIEdgeInsets = .zero
    weak var delegate: YMCalendarLayoutDelegate!

    var dayHeaderHeight: CGFloat = 15.0
    var contentSize: CGSize = .zero
    
    init(scrollDirection: YMScrollDirection) {
        self.scrollDirection = scrollDirection
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.scrollDirection = .horizontal
        super.init(coder: aDecoder)
    }

    fileprivate func widthForColumnRange(_ range: NSRange) -> CGFloat {
        let availableWidth = (collectionView?.bounds.size.width ?? 300) - (monthInsets.left + monthInsets.right)
        let columnWidth = availableWidth / 7
        
        if NSMaxRange(range) == 7 {
            return availableWidth - columnWidth * CGFloat((7 - range.length))
        }
        return columnWidth * CGFloat(range.length)
    }
    
    fileprivate func columnWidth(colIndex: Int) -> CGFloat {
        return widthForColumnRange(NSRange(location: colIndex, length: 1))
    }
    
    override func prepare() {
        
        let numberOfMonths = collectionView?.numberOfSections ?? 0
        
        var monthsAttrDict: AttrDict = [:]
        var dayCellsAttrDict: AttrDict = [:]
        var rowsAttrDict: AttrDict = [:]
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for month in 0..<numberOfMonths {
            /// 初日が何列目か
            var col: Int = delegate.collectionView(self.collectionView!, layout: self, columnForDayAtIndexPath: IndexPath(item: 0, section: month))
            let numberOfdaysInMonth: Int = self.collectionView?.numberOfItems(inSection: month) ?? 0
            let numberOfRows = Int(ceil(Double(col + numberOfdaysInMonth) / 7.0))
            let rowHeight = ((collectionView?.bounds.height ?? 300) - (monthInsets.top + monthInsets.bottom)) / CGFloat(numberOfRows)
            var day: Int = 0
            
            var monthRect = CGRect()
            monthRect.origin = CGPoint(x: x, y: y)
            
            y += monthInsets.top
            
            for _ in 0..<numberOfRows {
                let colRange = NSMakeRange(col, min(7 - col, numberOfdaysInMonth - day))
                if isShowEvents {
                    let path = IndexPath(item: day, section: month)
                    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ReusableIdentifier.Month.RowView.kind, with: path)
                    
                    let px: CGFloat
                    if scrollDirection == .vertical {
                        px = widthForColumnRange(NSRange(location: 0, length: col)) + monthInsets.left
                    } else {
                        px = widthForColumnRange(NSRange(location: 0, length: col)) + monthInsets.left + x
                    }
                    
                    let width = widthForColumnRange(NSRange(location: col, length: colRange.length))
                    attributes.frame = CGRect(x: px, y: y + dayHeaderHeight, width: width, height: rowHeight - dayHeaderHeight)
                    attributes.zIndex = 1
                    rowsAttrDict.updateValue(attributes, forKey: path)
                }
                
                while col < NSMaxRange(colRange) {
                    let path = IndexPath(item: day, section: month)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: path)
                    
                    let px: CGFloat
                    if scrollDirection == .vertical {
                        px = widthForColumnRange(NSRange(location: 0, length: col)) + monthInsets.left
                    } else {
                        px = widthForColumnRange(NSRange(location: 0, length: col)) + monthInsets.left + x
                    }
                    
                    let width = widthForColumnRange(NSRange(location: col, length: 1))
                    attributes.frame = CGRect(x: px, y: y, width: width, height: rowHeight)
                    dayCellsAttrDict.updateValue(attributes, forKey: path)
                    
                    col += 1
                    day += 1
                }
                
                y += rowHeight
                col = 0
            }
            
            if scrollDirection == .vertical {
                y += monthInsets.bottom
                
                monthRect.size = CGSize(width: collectionView?.bounds.size.width ?? 300, height: y - monthRect.origin.y)
            } else {
                
                x += collectionView?.bounds.size.width ?? 300
                y = 0
                
                monthRect.size = CGSize(width: x - monthRect.origin.x, height: collectionView?.bounds.height ?? 300)
                
            }
            
            let path = IndexPath(item: 0, section: month)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ReusableIdentifier.Month.BackgroundView.kind, with: path)
            attributes.frame = UIEdgeInsetsInsetRect(monthRect, monthInsets)
            attributes.zIndex = 2
            monthsAttrDict.updateValue(attributes, forKey: path)
        }
                
        if scrollDirection == .vertical {
            x = collectionView?.bounds.width ?? 300
        } else {
            y = collectionView?.bounds.height ?? 300
        }
        contentSize = CGSize(width: x, height: y)
        
        layoutAttrDict.updateValue(dayCellsAttrDict, forKey: "DayCellAttrDict")
        layoutAttrDict.updateValue(monthsAttrDict, forKey: "MonthsAttrDict")
        layoutAttrDict.updateValue(rowsAttrDict, forKey: "RowsAttrDict")
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layout = layoutAttrDict["DayCellAttrDict"],
            let attr = layout[indexPath] else {
            return nil
        }
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        layoutAttrDict.forEach { (kind, attributeDict) in
            attributeDict.forEach({ (path, attributes) in
                if rect.intersects(attributes.frame) {
                    allAttributes.append(attributes)
                }
            })
        }
        return allAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: UICollectionViewLayoutAttributes? = nil
        if elementKind == ReusableIdentifier.Month.BackgroundView.kind {
            if let layout = layoutAttrDict["MonthAttrDict"] {
                attributes = layout[indexPath]
            }
        } else if elementKind == ReusableIdentifier.Month.RowView.kind {
            if let layout = layoutAttrDict["RowsAttrDict"] {
                attributes = layout[indexPath]
            }
        }
        return attributes
    }
}
