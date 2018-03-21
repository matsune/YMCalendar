//
//  YMEventView.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/06.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit

open class YMEventView: UIView {
    
    var onTap: ((YMEventView) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapEventView(_:))))
    }
    
    @objc
    func didTapEventView(_ sender: UITapGestureRecognizer) {
        onTap?(self)
    }
}
