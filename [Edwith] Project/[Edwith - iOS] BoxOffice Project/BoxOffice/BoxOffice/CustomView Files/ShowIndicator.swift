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
    private var loadingAlert:   UIAlertController?
    internal static let shared: ShowIndicator = ShowIndicator()
    
    // MARK: - System Methods
    private override init() {}
    
    // MARK: - User Methods
    internal func showLoadIndicator(_ controller: UIViewController) {
        
        let message: String = "Just a moment..."
        
        // 네트워킹 동작중(로딩/새로고침)에는 상태표시줄(status bar)와 화면에 인디케이터를 사용해 사용자에게 네트워킹 중임을 정확히 표시해야 합니다.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // MARK: https://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios
            self.loadingAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            // MARK: Setting UIActivityIndicatorView
            let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            indicator.style             = .gray
            indicator.hidesWhenStopped  = true
            indicator.startAnimating()
            
            self.loadingAlert?.view.addSubview(indicator)
            
            // MARK: https://www.ioscreator.com/tutorials/activity-indicator-status-bar-ios-tutorial-ios12
            if let alert = self.loadingAlert {
                controller.present(alert, animated: true, completion: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
    internal func hideLoadIndicator() {
        
        DispatchQueue.main.async {
            self.loadingAlert?.dismiss(animated: true, completion: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
