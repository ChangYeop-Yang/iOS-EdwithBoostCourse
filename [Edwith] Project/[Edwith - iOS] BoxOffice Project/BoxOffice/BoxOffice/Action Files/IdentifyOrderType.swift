//
//  IdentifyOrderType.swift
//  BoxOffice
//
//  Created by 양창엽 on 08/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import Foundation

// MARK: - MovieFetchType Enum
internal enum MovieFetchType: String {
    case reservation    = "예매율순"
    case curation       = "큐레이션순"
    case launch         = "개봉일순"
}

internal var MOVIE_TYPE: Int = 0 // 예매율 (default) = 0, 1: 큐레이션, 2: 개봉일

// MARK: - Protocol Delegate
internal protocol MovieTypeDelegate: class {
    func changeMovieTypeEvent()
}
