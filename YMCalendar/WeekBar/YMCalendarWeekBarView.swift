//
//  YMCalendarWeekBarView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/25.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public class YMCalendarWeekBarView: UIView, YMCalendarWeekBarAppearance {
    
    public var appearance: YMCalendarWeekBarAppearance?
    
    public var calendar = Calendar.current {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var symbolLabels: [UILabel] = []
    
    public var gradientColors: [UIColor]?
    
    public var gradientLocations: [CGFloat] = [0.0, 1.0]
    
    public var gradientStartPoint = CGPoint(x: 0.5, y: 0.0)
    
    public var gradientEndPoint = CGPoint(x: 0.5, y: 1.0)
    
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
            let appearance = self.appearance ?? self
            symbolLabels[i].text = appearance.calendarWeekBarView(self, textAtWeekday: weekday)
            symbolLabels[i].textColor = appearance.calendarWeekBarView(self, textColorAtWeekday: weekday)
            symbolLabels[i].backgroundColor = appearance.calendarWeekBarView(self, backgroundColorAtWeekday: weekday)
            symbolLabels[i].font = appearance.calendarWeekBarView(self, fontAtWeekday: weekday)
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let c = UIGraphicsGetCurrentContext()
        
        if let gradientColors = gradientColors {
            let startColor = gradientColors[0].cgColor
            let endColor = gradientColors[1].cgColor
            let colors = [startColor, endColor] as CFArray
            
            let locations = gradientLocations
            
            let space = CGColorSpaceCreateDeviceRGB()
            
            let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locations)!
            let startPoint = CGPoint(x: rect.width * gradientStartPoint.x, y: rect.height * gradientStartPoint.y)
            let endPoint = CGPoint(x: rect.width * gradientEndPoint.x, y: rect.height * gradientEndPoint.y)
            c?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
        
        
        let colWidth = rect.width / 7
        let rowHeight = rect.height
        
        var x1: CGFloat
        var x2: CGFloat
        var y1: CGFloat
        var y2: CGFloat
        
        let appearance = self.appearance ?? self
        
        let horizontalGridWidth = appearance.weekBarHorizontalGridWidth(in: self)
        if horizontalGridWidth > 0 {
            c?.setStrokeColor(appearance.weekBarHorizontalGridColor(in: self).cgColor)
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
        
        let verticalGridWidth = appearance.weekBarVerticalGridWidth(in: self)
        if verticalGridWidth > 0 {
            c?.setStrokeColor(appearance.weekBarVerticalGridColor(in: self).cgColor)
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
