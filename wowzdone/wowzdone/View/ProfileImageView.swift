//
//  ProfileImageView.swift
//  wowzdone
//
//  Created by Leon Mak on 24/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.flatWhite.cgColor
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
