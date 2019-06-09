//
//  NotifyNotification.swift
//  BoxOffice
//
//  Created by 양창엽 on 08/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import Foundation

internal let GET_KEY: String = "GET_KEY"

// MARK: https://stackoverflow.com/questions/38889125/swift-3-how-to-use-enum-raw-value-as-nsnotification-name
internal enum NotificationName: String {
    case moviesListNoti        = "didReciveMovieListNotification"
    
    var name: Notification.Name {
        return Notification.Name(self.rawValue)
    }
}
