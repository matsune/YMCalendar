//
//  YMCalendarWeekBarView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/25.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit


public class YMCalendarWeekBarView: UIView, YMCalendarWeekBarDataSource {
    
    public var dataSource: YMCalendarWeekBarDataSource?
    
    public var calendar = Calendar.current
    
    private var symbolLabels: [UILabel] = []
    
    public var horizontalGridColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var horizontalGridWidth: CGFloat = 0.3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var verticalGridColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var verticalGridWidth: CGFloat = 0.3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
        
        for _ in 0..<7 {
            let label = UILabel()
            label.textAlignment = .center
            label.lineBreakMode = .byClipping
            symbolLabels.append(label)
            addSubview(label)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let colWidth = bounds.width / 7
        let firstWeekday = calendar.firstWeekday
        for i in 0..<symbolLabels.count {
            var weekday = firstWeekday + i
            if weekday > 7 {
                weekday %= 7
            }
            
            let x = CGFloat(i) * colWidth + colWidth / 2
            let y = bounds.height / 2
            let center = CGPoint(x: x, y: y)
            symbolLabels[i].frame.size = CGSize(width: colWidth, height: bounds.height)
            symbolLabels[i].center = center
            let dataSource = self.dataSource ?? self
            symbolLabels[i].text = dataSource.calendarWeekBarView(self, textAtWeekday: weekday)
            symbolLabels[i].textColor = dataSource.calendarWeekBarView(self, textColorAtWeekday: weekday)
            symbolLabels[i].backgroundColor = dataSource.calendarWeekBarView(self, backgroundColorAtWeekday: weekday)
            symbolLabels[i].font = dataSource.calendarWeekBarView(self, fontAtWeekday: weekday)
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let c = UIGraphicsGetCurrentContext()
        let colWidth = rect.width / 7
        let rowHeight = rect.height
        
        var x1: CGFloat
        var x2: CGFloat
        var y1: CGFloat
        var y2: CGFloat
        
        if horizontalGridWidth > 0 {
            c?.setStrokeColor(horizontalGridColor.cgColor)
            c?.setLineWidth(horizontalGridWidth)
            c?.beginPath()
            
            for y in 0...2 {
                x1 = 0
                x2 = rect.width
                y1 = rowHeight * CGFloat(y)
                y2 = y1
                
                c?.move(to: CGPoint(x: x1, y: y1))
                c?.addLine(to: CGPoint(x: x2, y: y2))
            }
            c?.strokePath()
        }
        
        if verticalGridWidth > 0 {
            c?.setStrokeColor(verticalGridColor.cgColor)
            c?.setLineWidth(verticalGridWidth)
            c?.beginPath()
            
            for x in 0...7 {
                x1 = colWidth * CGFloat(x)
                x2 = x1
                y1 = 0
                y2 = rect.height
                
                c?.move(to: CGPoint(x: x1, y: y1))
                c?.addLine(to: CGPoint(x: x2, y: y2))
            }
            c?.strokePath()
        }
    }
}
