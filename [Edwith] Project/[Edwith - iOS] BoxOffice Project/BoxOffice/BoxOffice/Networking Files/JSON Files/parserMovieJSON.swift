//
//  parserMovieJSON.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import Foundation

class parserMovieJSON: NSObject {
    
    // MARK: - Enum
    private enum SubURI: String {
        case movies = "/movies"
    }
    private enum HttpMethodType: String {
        case GET    = "GET"
        case POST   = "POST"
    }
    
    // MARK: - Object Variables
    private let BASE_SERVER_URL: String = "http://connect-boxoffice.run.goorm.io"
    
    // MARK: - User Method
    internal func fetchMovieListParser() {
        
        let parserAddress = String(format: "%s/%s", BASE_SERVER_URL, SubURI.movies.rawValue)
        
        guard let serverURL: URL = URL(string: parserAddress) else { return }
        
        var request: URLRequest = URLRequest(url: serverURL)
        request.httpMethod      = HttpMethodType.GET.rawValue
        
        let session: URLSession = URLSession(configuration: .default)
        
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
            
        }
    }
}
