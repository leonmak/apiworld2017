//
//  ProfileImageView.swift
//  wowzdone
//
//  Created by Leon Mak on 24/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    convenience init(frame: CGRect, border: CGColor=UIColor.flatWhite.cgColor) {
        self.init(frame: frame)
        self.layer.borderWidth = 3.0
        self.layer.borderColor = border
        self.layer.cornerRadius = 10.0
        
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
