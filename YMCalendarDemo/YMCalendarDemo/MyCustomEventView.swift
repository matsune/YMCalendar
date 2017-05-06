//
//  MyCustomEventView.swift
//  YMCalendarDemo
//
//  Created by Yuma Matsune on 5/6/17.
//  Copyright © 2017 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit
import YMCalendar

final class MyCustomEventView: YMEventView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 10.0)
        label.textAlignment = .center
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
