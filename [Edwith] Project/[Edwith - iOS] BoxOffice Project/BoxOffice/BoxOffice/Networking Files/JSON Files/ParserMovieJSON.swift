//
//  parserMovieJSON.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import Foundation

class ParserMovieJSON: NSObject {
    
    // MARK: - Enum
    internal enum SubURI: String {
        case movies = "/movies"
    }
    private enum HttpMethodType: String {
        case GET    = "GET"
        case POST   = "POST"
    }
    internal enum MovieParserType: Int {
        case movies = 0
    }
    
    // MARK: - Object Variables
    internal static let shared: ParserMovieJSON = ParserMovieJSON()
    private let BASE_SERVER_URL: String = "http://connect-boxoffice.run.goorm.io"
    
    private override init() {}
    
    // MARK: - User Method
    internal func fetchMovieDataParser(type: Int, subURI: String, parameter: String, _ viewType: Bool) {
        
        let parserAddress = "\(BASE_SERVER_URL)\(subURI)?\(parameter)"
        
        guard let serverURL: URL = URL(string: parserAddress) else { return }
        
        var request: URLRequest = URLRequest(url: serverURL)
        request.httpMethod      = HttpMethodType.GET.rawValue
        
        let session: URLSession = URLSession(configuration: .default)
        
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                print("‼️ Error, Could't URLSeesionDataTask. \(String(describing: error))")
                return
            }
            
            // MARK: https://www.raywenderlich.com/567-urlsession-tutorial-getting-started
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                
                guard let type = MovieParserType(rawValue: type) else { return }
                
                do {
                    
                    switch type {
                        case .movies:
                            let result  = try JSONDecoder().decode(Movies.self, from: data)
                            NotificationCenter.default.post(name: NotificationName.moviesListNoti.name, object: nil, userInfo: [GET_KEY: result.movies])
                    }
                    
                    // MARK: Hide Indicator
                    ShowIndicator.shared.hideLoadIndicator()
                } catch let error { print(error.localizedDescription) }
            }
        }
        
        dataTask.resume()
    }
}
