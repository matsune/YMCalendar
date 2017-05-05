//
//  ReusableObject.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/07.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

/// ReusableObject will be reused for many times, such as UICollectionViewCell.
/// This object can be registared and dequeued. 
public protocol ReusableObject: class {
    
    init()
    
    var reuseIdentifier: String { get set }
    
    func prepareForReuse()
}
