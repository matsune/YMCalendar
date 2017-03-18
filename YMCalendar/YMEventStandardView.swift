//
//  YMEventStandardView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/09.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public class YMEventStandardView: YMEventView {
    
    let kSpace: CGFloat = 2
    
    public var title: String = ""
    
    public var color: UIColor = .black
    
    public var font: UIFont = .systemFont(ofSize: 12.0)
    
    public var attrString = NSMutableAttributedString()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        setNeedsDisplay()
    }
    
    func redrawStringInRect(_ rect: CGRect) {
        var s = ""
        s += title
        
        let attributedString = NSMutableAttributedString(string: s, attributes: [NSFontAttributeName : font])
        
        let c: UIColor = selected ? .white : color
        attributedString.addAttribute(NSForegroundColorAttributeName, value: c, range: NSMakeRange(0, attributedString.length))
        
        attrString = attributedString
    }
    
    override public func draw(_ rect: CGRect) {
        let drawRect = rect.insetBy(dx: kSpace, dy: 0)
        redrawStringInRect(drawRect)
        
        attrString.draw(with: drawRect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], context: nil)
    }
}
