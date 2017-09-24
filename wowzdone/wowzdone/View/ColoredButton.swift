//
//  ColoredButton.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import ChameleonFramework

class ColoredButton: UIButton {
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.backgroundColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 6
        
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = false
        self.layer.borderWidth = 1.0
        
        self.layer.shadowColor = UIColor.flatGray.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 6.0, height: 6.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
