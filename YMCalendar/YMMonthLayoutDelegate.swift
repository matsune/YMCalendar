//
//  MonthLayoutDelegate.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

protocol YMMonthLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: YMMonthLayout, columnForDayAtIndexPath indexPath: IndexPath) -> Int
}
