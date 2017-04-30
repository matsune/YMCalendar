//
//  YMCollectionReusable.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

internal protocol YMCollectionReusable {}

extension YMCollectionReusable where Self: UICollectionReusableView {
    static var kind: String {
        return "\(type(of: self))Kind"
    }
    
    static var identifier: String {
        return "\(type(of: self))Identifier"
    }
}
