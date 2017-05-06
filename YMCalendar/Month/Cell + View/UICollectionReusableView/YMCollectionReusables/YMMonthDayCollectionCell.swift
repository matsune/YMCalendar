//
//  YMMonthDayCollectionCell.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/02/21.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

final internal class YMMonthDayCollectionCell: UICollectionViewCell, YMCollectionReusable {
    typealias YMMonthDayAnimationCompletion = (Bool) -> ()
    
    let dayLabel = UILabel()
    
    var dayLabelColor: UIColor = .black {
        didSet {
            dayLabel.textColor = dayLabelColor
        }
    }
    
    var dayLabelBackgroundColor: UIColor = .clear {
        didSet {
            dayLabel.backgroundColor = dayLabelBackgroundColor
        }
    }
    
    var dayLabelSelectedColor: UIColor = .white
    
    var dayLabelSelectedBackgroundColor: UIColor = .black
    
    var day: Int = 1 {
        didSet {
            dayLabel.text = "\(day)"
        }
    }
    
    var dayLabelAlignment: YMDayLabelAlignment = .left
    
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
        backgroundColor = .clear
        
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
        
        let x: CGFloat
        switch dayLabelAlignment {
        case .left:
            x = dayLabelMargin
            dayLabel.frame = CGRect(x: dayLabelMargin, y: dayLabelMargin, width: dayLabelHeight, height: dayLabelHeight)
        case .center:
            x = (bounds.width - dayLabelHeight)/2
        case .right:
            x = bounds.width - dayLabelMargin - dayLabelHeight
        }
        dayLabel.frame = CGRect(x: x, y: dayLabelMargin, width: dayLabelHeight, height: dayLabelHeight)
        dayLabel.layer.cornerRadius = dayLabelHeight / 2
    }
    
    public func select(withAnimation animation: YMSelectAnimation, completion: YMMonthDayAnimationCompletion? = nil) {
        switch animation {
        case .none:
            animationWithNone(true, completion: completion)
        case .bounce:
            animationWithBounce(true, completion: completion)
        case .fade:
            animationWithFade(true, completion: completion)
        }
    }
    
    public func deselect(withAnimation animation: YMSelectAnimation, completion: YMMonthDayAnimationCompletion? = nil) {
        switch animation {
        case .none:
            animationWithNone(false, completion: completion)
        case .bounce:
            animationWithBounce(false, completion: completion)
        case .fade:
            animationWithFade(false, completion: completion)
        }
    }
    
    // - MARK: Animation None
    private func animationWithNone(_ isSelected: Bool, completion: YMMonthDayAnimationCompletion?=nil) {
        if isSelected {
            dayLabel.textColor = dayLabelSelectedColor
            dayLabel.backgroundColor = dayLabelSelectedBackgroundColor
        } else {
            dayLabel.textColor = dayLabelColor
            dayLabel.backgroundColor = dayLabelBackgroundColor
        }
        completion?(true)
    }
    
    // - MARK: Animation Bounce
    private func animationWithBounce(_ isSelected: Bool, completion: YMMonthDayAnimationCompletion?) {
        dayLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options: .beginFromCurrentState,
                       animations: {
                        self.dayLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                        
                        self.animationWithNone(isSelected)
                       }, completion: completion)
    }
    
    // - MARK: Animation Fade
    private func animationWithFade(_ isSelected: Bool, completion: YMMonthDayAnimationCompletion?) {
        UIView.transition(with: dayLabel,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { 
                            self.animationWithNone(isSelected)
                          }, completion: completion)
    }
}
