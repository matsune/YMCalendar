//
//  YMCalendarLayoutDataSource.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

protocol YMCalendarLayoutDataSource: class {
    func collectionView(_ collectionView: UICollectionView, layout: YMCalendarLayout, columnAt indexPath: IndexPath) -> Int
}
