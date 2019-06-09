//
//  ShowIndicator.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class ShowIndicator: NSObject {
    
    // MARK: - Outlet Variables
    private var screen: UIView?
    private var indicator: UIActivityIndicatorView?
    
    internal func showLoadIndicator(controller: UIViewController) {
        
        // MARK: Setting Background UIView
        self.screen                     = UIView(frame: controller.view.frame)
        self.screen?.backgroundColor    = UIColor.darkGray
        self.screen?.alpha              = 0.8
        
        // MARK: Setting UIActivityIndicatorView
        
        
        if let backgroundView = self.screen {
            controller.view.addSubview(backgroundView)
        }
    }
    
    internal func hideLoadIndicator() {
        
    }
}
