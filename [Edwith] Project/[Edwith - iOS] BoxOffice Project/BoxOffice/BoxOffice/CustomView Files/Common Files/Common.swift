//
//  Common.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

// MARK: - WatchAge Enum
internal enum WatchAge: Int {
    case all        = 0
    case twelve     = 12
    case fifteen    = 15
    case nineteen   = 19
}

// MARK: - Seperate Age Type Method (Convert Int -> UIImage)
internal func seperateAgeType(age: Int, imageView: UIImageView) {
    guard let type = WatchAge(rawValue: age) else { return }
    
    switch type {
        case .all:
            imageView.image = UIImage(named: "ic_allages")
        case .twelve:
            imageView.image = UIImage(named: "ic_12")
        case .fifteen:
            imageView.image = UIImage(named: "ic_15")
        case .nineteen:
            imageView.image = UIImage(named: "ic_19")
    }
}
