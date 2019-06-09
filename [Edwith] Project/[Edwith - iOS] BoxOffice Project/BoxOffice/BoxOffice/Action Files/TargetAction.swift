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
    
    private override init() {}
    
    // MARK: - User Methods
    internal func showMovieTypeActionSheet(_ controller: UIViewController) {
        
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
}
