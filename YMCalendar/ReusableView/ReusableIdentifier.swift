//
//  ReusableIdentifier.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

protocol ReusableIdentifiable: RawRepresentable {}

extension ReusableIdentifiable where Self.RawValue == String {
    var kind: String {
        return "\(type(of: self))" + rawValue + "Kind"
    }
    
    var identifier: String {
        return "\(type(of: self))" + rawValue + "Identifier"
    }
}

struct ReusableIdentifier {
    enum Events: String, ReusableIdentifiable {
        case rowView
        case standardView
        
        var classType: ReusableObject.Type {
            switch self {
            case .rowView:
                return YMEventsRowView.self
            case .standardView:
                return YMEventStandardView.self
            }
        }
    }
    
    enum Month: String, ReusableIdentifiable {
        case DayCell
        case BackgroundView
        case RowView
        
        var classType: AnyClass {
            switch self {
            case .DayCell:
                return YMMonthDayCollectionCell.self
            case .BackgroundView:
                return YMMonthBackgroundView.self
            case .RowView:
                return YMMonthWeekView.self
            }
        }
    }
}
