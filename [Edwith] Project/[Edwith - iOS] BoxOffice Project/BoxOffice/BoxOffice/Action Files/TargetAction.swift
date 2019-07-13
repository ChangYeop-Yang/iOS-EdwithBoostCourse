//
//  ParserData.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class TargetAction: NSObject {
    
    // MARK: - Object Variables
    internal var delegate: MovieTypeDelegate?
    internal static let shared: TargetAction = TargetAction()
    
    // MARK: - Init
    private override init() {}
}

// MARK: - Private Extension TargetAction
private extension TargetAction {
    
    func getTopMostViewController() -> UIViewController? {
        
        // https://stackoverflow.com/questions/54209766/swift-4-attempt-to-present-viewcontroller-whose-view-is-not-in-the-window-hierar
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        
        return topMostViewController
    }
}

// MARK: - Internal Extension TargetAction
internal extension TargetAction {
    
    // MARK: - User Methods
    func showMovieTypeActionSheet(_ controller: UIViewController) {
        
        DispatchQueue.main.async {
            
            let actionSheet = UIAlertController(title: "정렬방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: .actionSheet)
            
            let handler: (UIAlertAction) -> Void = { alert in
                
                guard let title = alert.title, let movieType = MovieFetchType(rawValue: title) else { return }
                
                DispatchQueue.main.async {
                    switch movieType {
                    case .reservation:
                        MOVIE_TYPE                  = 0
                        controller.parent?.title    = MovieFetchType.reservation.rawValue
                    case .curation:
                        MOVIE_TYPE                  = 1
                        controller.parent?.title    = MovieFetchType.curation.rawValue
                    case .launch:
                        MOVIE_TYPE                  = 2
                        controller.parent?.title    = MovieFetchType.launch.rawValue
                    }
                    
                    self.delegate?.changeMovieTypeEvent()
                }
            }
            
            let actionReservation = UIAlertAction(title: MovieFetchType.reservation.rawValue, style: .default, handler: handler)
            actionSheet.addAction(actionReservation)
            
            let actionCuration = UIAlertAction(title: MovieFetchType.curation.rawValue, style: .default, handler: handler)
            actionSheet.addAction(actionCuration)
            
            let actionLaunch = UIAlertAction(title: MovieFetchType.launch.rawValue, style: .default, handler: handler)
            actionSheet.addAction(actionLaunch)
            
            let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            actionSheet.addAction(actionCancel)
            
            controller.present(actionSheet, animated: true, completion: nil)
        }
    }
    func showErrorAlert(message: String) {
        
        // MARK: Hide Load Data Indicator.
        ShowIndicator.shared.hideLoadIndicator()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "‼️ System Error Alert", message: message, preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "✅ 확인", style: .default, handler: nil)
            alert.addAction(confirm)
            
            self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
}
