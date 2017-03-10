//
//  MonthDayCollectionCell.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final class YMMonthDayCollectionCell: UICollectionViewCell {

    private let dayLabel = UILabel()
    
    var dayLabelColor: UIColor = .black {
        didSet {
            dayLabel.textColor = dayLabelColor
        }
    }
    
    var headerHeight: CGFloat = 15 {
        didSet {
            setNeedsLayout()
        }
    }
    
    let headerMargin: CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        
        dayLabel.numberOfLines = 1
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.font = UIFont.systemFont(ofSize: 12.0)
        dayLabel.textColor = dayLabelColor
        contentView.addSubview(dayLabel)
        
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.7, alpha: 0.2)
        selectedBackgroundView = view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let headerFrame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: headerHeight)
        dayLabel.frame = headerFrame.insetBy(dx: headerMargin, dy: headerMargin)
    }
    
    func setDay(_ day: Int) {
        dayLabel.text = "\(day)"
    }
}
