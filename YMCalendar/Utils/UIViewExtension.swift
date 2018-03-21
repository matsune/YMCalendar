//
//  UIViewExtension.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/21.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public convenience init<V>(style: Style<V>) {
        self.init(frame: .zero)
        apply(style)
    }
    
    public func apply<V>(_ style: Style<V>) {
        guard let view = self as? V else {
            return
        }
        style.apply(to: view)
    }
}
