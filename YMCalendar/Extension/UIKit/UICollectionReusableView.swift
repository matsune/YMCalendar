//
//  UICollectionReusableView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/21.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionReusableView: ExtensionCompatible {}

extension Extension where Base: UICollectionReusableView {
    static var kind: String {
        return "\(type(of: self))Kind"
    }
    
    static var identifier: String {
        return "\(type(of: self))Identifier"
    }
}
