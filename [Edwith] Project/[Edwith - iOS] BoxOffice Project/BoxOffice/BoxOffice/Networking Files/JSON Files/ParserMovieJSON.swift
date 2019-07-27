//
//  parserMovieJSON.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class ParserMovieJSON: NSObject {
    
    // MARK: - Enum
    private enum HTTPMethodType: String {
        case GET    = "GET"
        case POST   = "POST"
    }
    internal enum SubURI: String {
        case movies     = "/movies"
        case movie      = "/movie"
        case comment    = "/comments"
        case upload     = "/comment"
    }
    internal enum MovieParserType: Int {
        case movies     = 0
        case movie      = 1
        case comment    = 2
    }
    
    // MARK: - Object Variables
    internal static let shared: ParserMovieJSON = ParserMovieJSON()
    private let BASE_SERVER_URL: String = "http://connect-boxoffice.run.goorm.io"
    
    private let SUCCESS_HTTP_CODE: Int = 200
    
    // MARK: - Init
    private override init() {}
}

// MARK: - Private Extension ParserMovieJSON
private extension ParserMovieJSON {
    
    func showNetworkErrorAlert(message: String, code: Int) {
        let message = "Error, Could't URLSeesionDataTask - \(message). \(code)"
        
        TargetAction.shared.showErrorAlert(message: message)
    }
}

// MARK: - Internal Extension ParserMovieJSON
internal extension ParserMovieJSON {
    
    func fetchMovieDataParser(type: Int, subURI: String, parameter: String) {
        
        let parserAddress = "\(BASE_SERVER_URL)\(subURI)?\(parameter)"
        
        guard let serverURL: URL = URL(string: parserAddress) else { return }
        
        var request: URLRequest = URLRequest(url: serverURL)
        request.httpMethod      = HTTPMethodType.GET.rawValue
        
        let session: URLSession = URLSession(configuration: .default)
        
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { [weak self] data, response, error in
            
            // https://ko.wikipedia.org/wiki/HTTP_상태_코드
            guard let response = response as? HTTPURLResponse, let self = self else { return }
            
            // 데이터 수신 또는 한줄평 등록에 실패한 경우, 알림창을 통해 사용자에게 결과를 표시해야 합니다.
            guard error == nil, response.statusCode == self.SUCCESS_HTTP_CODE else {
                self.showNetworkErrorAlert(message: error.debugDescription, code: response.statusCode)
                return
            }
            
            // MARK: https://www.raywenderlich.com/567-urlsession-tutorial-getting-started
            if let data = data, response.statusCode == self.SUCCESS_HTTP_CODE {
                
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
                    TargetAction.shared.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
        
        dataTask.resume()
    }
    func uploadMovieUserComment(type: Int, subURI: String, parameter: UserComment) {
        
        let uploadAddress = "\(BASE_SERVER_URL)\(subURI)"
        
        let handler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            
            // 데이터 수신 또는 한줄평 등록에 실패한 경우, 알림창을 통해 사용자에게 결과를 표시해야 합니다.
            guard let response = response as? HTTPURLResponse, response.statusCode == self.SUCCESS_HTTP_CODE else {
                NotificationCenter.default.post(name: NotificationName.movieUserUploadComment.name, object: nil, userInfo: [GET_KEY: false])
                return
            }
            
            NotificationCenter.default.post(name: NotificationName.movieUserUploadComment.name, object: nil, userInfo: [GET_KEY: true])
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url: URL = URL(string: uploadAddress) else { return }
            
            // 😅 API를 통해 한줄평 등록을 완료 한 후 Notification으로 응답을 처리하고 있습니다. Notification 이외의 값을 던져줄 방법이 있는지 궁금합니다! 오류의 값!
            guard let json = try? JSONEncoder().encode(parameter) else {
                NotificationCenter.default.post(name: NotificationName.movieUserUploadComment.name, object: nil, userInfo: [GET_KEY: false])
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
