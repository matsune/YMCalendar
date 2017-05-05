//
//  YMMonthWeekView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final internal class YMMonthWeekView: UICollectionReusableView, YMCollectionReusable {

    var eventsView = YMEventsRowView(frame: .zero) {
        didSet {
            oldValue.removeFromSuperview()
            addSubview(eventsView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        addSubview(eventsView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventsView.frame = bounds
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
