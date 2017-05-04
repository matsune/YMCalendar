//
//  YMMonthBackgroundView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final internal class YMMonthBackgroundView: UICollectionReusableView, YMCollectionReusable {
    
    // number of days in week
    let numberOfColumns: Int = 7
    
    // number of week in month
    var numberOfRows: Int = 0
    
    // which column the last day of month is
    var lastColumn: Int = 7
    
    var horizontalGridWidth: CGFloat = 0.3
    var horizontalGridColor: UIColor = .black
    var verticalGridWidth: CGFloat = 0.3
    var verticalGridColor: UIColor = .black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()
        
        let colWidth = numberOfColumns > 0 ? (bounds.width / CGFloat(numberOfColumns)) : bounds.width
        let rowHeight = numberOfRows > 0 ? (bounds.height / CGFloat(numberOfRows)) : bounds.height
        
        var x1: CGFloat
        var y1: CGFloat
        var x2: CGFloat
        var y2: CGFloat
        
        c?.setStrokeColor(horizontalGridColor.cgColor)
        c?.setLineWidth(horizontalGridWidth)
        c?.beginPath()
        
        if horizontalGridWidth > 0 {
            var i: Int = 0
            while i <= numberOfRows && numberOfRows != 0 {
                y1 = rowHeight * CGFloat(i)
                y2 = y1
                x1 = 0
                x2 = rect.maxX
                
                c?.move(to: CGPoint(x: x1, y: y1))
                c?.addLine(to: CGPoint(x: x2, y: y2))
                
                i += 1
            }
        }
        
        c?.strokePath()
        
        c?.setStrokeColor(verticalGridColor.cgColor)
        c?.setLineWidth(verticalGridWidth)
        c?.beginPath()
        
        if verticalGridWidth > 0 {
            for j in 0...numberOfColumns {
                x1 = colWidth * CGFloat(j)
                x2 = x1
                y1 = 0
                y2 = rect.maxY
                
                c?.move(to: CGPoint(x: x1, y: y1))
                c?.addLine(to: CGPoint(x: x2, y: y2))
            }
        }
        
        c?.strokePath()
    }
}
