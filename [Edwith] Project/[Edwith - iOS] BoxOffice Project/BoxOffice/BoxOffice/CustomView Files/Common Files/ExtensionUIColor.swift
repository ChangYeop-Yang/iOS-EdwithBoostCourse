//
//  ExtensionUIColor.swift
//  BoxOffice
//
//  Created by 양창엽 on 10/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - https://stackoverflow.com/questions/19032940/how-can-i-get-the-ios-7-default-blue-color-programmatically
    static var systemColor: UIColor {
        return UIButton(type: .system).tintColor
    }
}
