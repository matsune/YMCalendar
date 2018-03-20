//
//  ReusableObject.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/07.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

public protocol ReusableObject: class {
    
    init()
    
    var reuseIdentifier: String { get set }
    
    func prepareForReuse()
}
