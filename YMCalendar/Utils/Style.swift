//
//  Style.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/21.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

public struct Style<View: UIView> {

    public let style: (View) -> Void

    public init(_ style: @escaping (View) -> Void) {
        self.style = style
    }

    public func apply(to view: View) {
        style(view)
    }
}
