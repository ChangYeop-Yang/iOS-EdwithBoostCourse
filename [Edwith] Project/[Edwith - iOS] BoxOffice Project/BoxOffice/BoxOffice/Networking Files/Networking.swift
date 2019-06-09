//
//  Networking.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class Networking: NSObject {
    
    // MARK: - Object Variables
    internal static let shared: Networking = Networking()
    
    // MARK: - System Methods
    private override init() {}
    
    // MARK: - User Methods
    internal func downloadImage(url: String, group: DispatchGroup, imageView: UIImageView) {
        
        var image: UIImage?
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async(group: group) {
            
            guard let imageURL: URL = URL(string: url) else {
                group.leave()
                return
            }
            
            let session: URLSession = URLSession(configuration: .default)
            let dataTask: URLSessionDataTask = session.dataTask(with: imageURL) { data, response, error in
                
                guard error == nil else {
                    print("‼️ Error, URLSessionDataTask from server. \(String(describing: error))")
                    group.leave()
                    return
                }
                
                if let result = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    image = UIImage(data: result)
                }
                
                group.leave()
            }
            
            dataTask.resume()
        }
        
        group.notify(queue: .main) {
            guard let movieImage = image else { return }
            
            imageView.image = movieImage
        }
    }
}
