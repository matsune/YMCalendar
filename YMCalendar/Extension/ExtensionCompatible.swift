//
//  ExtensionCompatible.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/21.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation

struct Extension<Base> {
    let base: Base
    init (_ base: Base) {
        self.base = base
    }
}

protocol ExtensionCompatible {
    associatedtype Compatible
    static var ym: Extension<Compatible>.Type { get }
    var ym: Extension<Compatible> { get }
}

extension ExtensionCompatible {
    static var ym: Extension<Self>.Type {
        return Extension<Self>.self
    }
    
    var ym: Extension<Self> {
        return Extension(self)
    }
}
