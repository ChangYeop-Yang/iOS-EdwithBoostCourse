//
//  ParserData.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

internal enum MovieFetchType: String {
    case reservation    = "예매율"
    case curation       = "큐레이션"
    case launch         = "개봉일"
}

internal var MOVIE_TYPE: Int = 0 // 예매율 (default) = 0, 1: 큐레이션, 2: 개봉일

internal func showMovieTypeActionSheet(_ controller: UIViewController) {
    
    DispatchQueue.main.async {
        let actionSheet = UIAlertController(title: "정렬방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: .actionSheet)
        
        let handler: (UIAlertAction) -> Void = { alert in
            
            guard let title = alert.title, let type = MovieFetchType(rawValue: title) else { return }
            
            DispatchQueue.main.async {
                switch type {
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
