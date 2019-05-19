//
//  RoundImageView.swift
//  MyAlbum
//
//  Created by 양창엽 on 19/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    // MARK: - Object Variables
    private let cornerRadius: CGFloat = 10
    
    // MARK: https://stackoverflow.com/questions/27861383/how-to-set-corner-radius-of-imageview
    override func awakeFromNib() {
        self.layer.masksToBounds    = true
        self.layer.cornerRadius     = self.cornerRadius
    }
    
}
