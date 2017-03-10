//
//  YMMonthBackgroundView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final class YMMonthBackgroundView: UICollectionReusableView, YMMonthBackgroundAppearance {
    
    var numberOfColumns: Int = 7
    var numberOfRows: Int = 0
    var lastColumn: Int = 7
    
    weak var appearance: YMMonthBackgroundAppearance?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
        appearance = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAppearance(_ appearance: YMMonthBackgroundAppearance, numberOfColumns: Int, numberOfRows: Int, lastColumn: Int) {
        self.appearance = appearance
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {

        let appearance: YMMonthBackgroundAppearance = self.appearance ?? self

        let c = UIGraphicsGetCurrentContext()
        
        let colWidth = numberOfColumns > 0 ? (bounds.width / CGFloat(numberOfColumns)) : bounds.width
        let rowHeight = numberOfRows > 0 ? (bounds.height / CGFloat(numberOfRows)) : bounds.height
        
        c?.setStrokeColor(appearance.gridColor().cgColor)
        c?.setLineWidth(appearance.gridLineWidth())
        
        c?.beginPath()
        
        var x1: CGFloat
        var y1: CGFloat
        var x2: CGFloat
        var y2: CGFloat
        
        if appearance.isDrawHorizontalLines() {
            var i: Int = 0
            while i <= numberOfRows && numberOfRows != 0 {
                y1 = rowHeight * CGFloat(i)
                y2 = y1
                x1 = 0
                x2 = i == numberOfRows ? CGFloat(lastColumn) * colWidth : rect.maxX

                c?.move(to: CGPoint(x: x1, y: y1))
                c?.addLine(to: CGPoint(x: x2, y: y2))
                
                i += 1
            }
        }
        
        if appearance.isDrawVerticalLines() {
            for j in 0...numberOfColumns {
                x1 = colWidth * CGFloat(j)
                x2 = x1
                y1 = 0
                y2 = j <= lastColumn ? CGFloat(numberOfRows) * rowHeight : CGFloat(numberOfRows - 1) * rowHeight
                
                c?.move(to: CGPoint(x: x1, y: y1))
                c?.addLine(to: CGPoint(x: x2, y: y2))
            }
        }
        
        c?.strokePath()
    }
}
