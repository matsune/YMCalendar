//
//  UICollectionView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2018/03/21.
//  Copyright © 2018年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView: ExtensionCompatible {}

extension Extension where Base: UICollectionView {
    func register<T: UICollectionReusableView>(_ type: T.Type) {
        if type is UICollectionViewCell.Type {
            base.register(type, forCellWithReuseIdentifier: type.ym.identifier)
        } else {
            base.register(type, forSupplementaryViewOfKind: type.ym.kind, withReuseIdentifier: type.ym.identifier)
        }
    }

    func dequeue<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
        if type is UICollectionViewCell.Type {
            guard let cell = base.dequeueReusableCell(withReuseIdentifier: type.ym.identifier, for: indexPath) as? T else {
                fatalError("Failed to dequeue type \(type)")
            }
            return cell
        } else {
            guard let view = base.dequeueReusableSupplementaryView(ofKind: type.ym.kind, withReuseIdentifier: type.ym.identifier, for: indexPath) as? T else {
                fatalError("Failed to dequeue type \(type)")
            }
            return view
        }
    }
}
