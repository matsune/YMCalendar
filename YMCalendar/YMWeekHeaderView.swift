//
//  WeekHeaderView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final class YMWeekHeaderView: UIView {

    var symbols: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var symbolLabels: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        (0..<7).forEach { i in
            let label = UILabel(frame: CGRect.zero)
            label.textAlignment = .center
            label.text = symbols[i]
            symbolLabels.append(label)
            addSubview(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for i in 0..<symbolLabels.count {
            let w = bounds.width / CGFloat(symbolLabels.count)
            let x = w * CGFloat(i)
            symbolLabels[i].frame = CGRect(x: x, y: 0, width: w, height: bounds.height)
        }
    }
}
