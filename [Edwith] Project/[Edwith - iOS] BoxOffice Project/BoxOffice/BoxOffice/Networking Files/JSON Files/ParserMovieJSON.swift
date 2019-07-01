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
        case movies     = "/movies"
        case movie      = "/movie"
        case comment    = "/comments"
        case upload     = "/comment"
    }
    private enum HTTPMethodType: String {
        case GET    = "GET"
        case POST   = "POST"
    }
    internal enum MovieParserType: Int {
        case movies     = 0
        case movie      = 1
        case comment    = 2
    }
    
    // MARK: - Object Variables
    internal static let shared: ParserMovieJSON = ParserMovieJSON()
    private let BASE_SERVER_URL: String = "http://connect-boxoffice.run.goorm.io"
    
    // MARK: - Init
    private override init() {}
    
    // MARK: - User Method
    internal func fetchMovieDataParser(type: Int, subURI: String, parameter: String) {
        
        let parserAddress = "\(BASE_SERVER_URL)\(subURI)?\(parameter)"
        
        guard let serverURL: URL = URL(string: parserAddress) else { return }
        
        var request: URLRequest = URLRequest(url: serverURL)
        request.httpMethod      = HTTPMethodType.GET.rawValue
    
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
                        
                        case .movie:
                            let result  = try JSONDecoder().decode(MovieDetailInformation.self, from: data)
                            NotificationCenter.default.post(name: NotificationName.movieDetailNoti.name, object: nil, userInfo: [GET_KEY: result])
                        
                        case .comment:
                            let result  = try JSONDecoder().decode(Comment.self, from: data)
                            NotificationCenter.default.post(name: NotificationName.movieUserComment.name, object: nil, userInfo: [GET_KEY: result])
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }

        }
        
        dataTask.resume()
    }
    internal func uploadMovieUserComment(type: Int, subURI: String, parameter: UserComment) {
        
        let uploadAddress = "\(BASE_SERVER_URL)\(subURI)"
        
        let handler: (Data?, URLResponse?, Error?) -> Void = {  data, response, error in
            
            // 데이터 수신 또는 한줄평 등록에 실패한 경우, 알림창을 통해 사용자에게 결과를 표시해야 합니다.
            guard error == nil else {
                print("‼️ Error, Upload \(String(describing: error?.localizedDescription))")
                return
            }
            
            // Success Status Code : 200
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                NotificationCenter.default.post(name: NotificationName.movieUserUploadComment.name, object: nil, userInfo: [GET_KEY: false])
                return
            }
            
            NotificationCenter.default.post(name: NotificationName.movieUserUploadComment.name, object: nil, userInfo: [GET_KEY: true])
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url: URL = URL(string: uploadAddress) else { return }
            
            guard let json = try? JSONEncoder().encode(parameter) else {
                print("‼️ Error, JSON Encode to parameter.")
                return
            }
            
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod      = HTTPMethodType.POST.rawValue
            request.httpBody        = json
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
            URLSession.shared.dataTask(with: request, completionHandler: handler).resume()
        }
    }
}
