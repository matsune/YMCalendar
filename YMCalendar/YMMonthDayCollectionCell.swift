//
//  YMMonthDayCollectionCell.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final public class YMMonthDayCollectionCell: UICollectionViewCell {

    public let dayLabel = UILabel()
    
    public var dayLabelColor: UIColor = .black {
        didSet {
            dayLabel.textColor = dayLabelColor
        }
    }
    
    public var dayLabelBackgroundColor: UIColor = .clear {
        didSet {
            dayLabel.backgroundColor = dayLabelBackgroundColor
        }
    }
    
    public var dayLabelSelectionColor: UIColor = .white
    
    public var dayLabelSelectionBackgroundColor: UIColor = .black
    
    public var day: Int = 0 {
        didSet {
            dayLabel.text = "\(day)"
        }
    }
    
    var dayLabelHeight: CGFloat = 15
    
    let dayLabelMargin: CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        
        dayLabel.numberOfLines = 1
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.font = UIFont.systemFont(ofSize: 12.0)
        dayLabel.textColor = dayLabelColor
        dayLabel.layer.masksToBounds = true
        dayLabel.textAlignment = .center
        contentView.addSubview(dayLabel)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        dayLabel.frame = CGRect(x: dayLabelMargin, y: dayLabelMargin, width: dayLabelHeight, height: dayLabelHeight)
        dayLabel.layer.cornerRadius = dayLabelHeight / 2
    }
    
    public func animateSelection(withAnimation animation: YMCalendarSelectionAnimation) {
        switch animation {
        case .none:
            animationWithNone(true)
        case .bounce:
            animationWithBounce(true)
        case .fade:
            animationWithFade(true)
        }
    }
    
    public func animateDeselection(withAnimation animation: YMCalendarSelectionAnimation) {
        switch animation {
        case .none:
            animationWithNone(false)
        case .bounce:
            animationWithBounce(false)
        case .fade:
            animationWithFade(false
            )
        }
    }
    
    // MARK: None
    private func animationWithNone(_ selected: Bool) {
        if selected {
            dayLabel.textColor = dayLabelSelectionColor
            dayLabel.backgroundColor = dayLabelSelectionBackgroundColor
        } else {
            dayLabel.textColor = dayLabelColor
            dayLabel.backgroundColor = dayLabelBackgroundColor
        }
    }
    
    // MARK: Bounce
    private func animationWithBounce(_ selected: Bool) {
        dayLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options: .beginFromCurrentState,
                       animations: {
                        self.dayLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                        
                        self.animationWithNone(selected)
        }, completion: nil)
    }
    
    // MARK: Fade
    private func animationWithFade(_ selected: Bool) {
        UIView.transition(with: dayLabel,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { 
                            self.animationWithNone(selected)
                          }, completion: nil)
    }
}
