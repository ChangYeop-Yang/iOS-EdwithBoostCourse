//
//  MovieTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    // MARK: - Enum
    private enum WatchAge: Int {
        case all        = 0
        case twelve     = 12
        case fifteen    = 15
        case nineteen   = 19
    }

    // MARK: - Outlet Variables
    @IBOutlet private weak var presentMovieImageView:       UIImageView!
    @IBOutlet private weak var presentMovieTitleLabel:      UILabel!
    @IBOutlet private weak var presentMovieAgeImageView:    UIImageView!
    @IBOutlet private weak var presentMovieRatingLabel:     UILabel!
    @IBOutlet private weak var presentMovieRankingLabel:    UILabel!
    @IBOutlet private weak var presentMovieRateLabel:       UILabel!
    @IBOutlet private weak var presentMovieLaunchLabel:     UILabel!
    
    // MARK: - User Method
    internal func setPresentMovieData(movieData: MovieList) {
        
        self.presentMovieTitleLabel.text    = movieData.title
        self.presentMovieLaunchLabel.text   = "개봉일 : \(movieData.date)"
        self.presentMovieRatingLabel.text   = String(format: "평점 : %.2f", movieData.userRating)
        self.presentMovieRankingLabel.text  = "예매순위 : \(movieData.reservationGrade)"
        self.presentMovieRateLabel.text     = String(format: "예매율 : %.2f", movieData.reservationRate)
        
        seperateAgeType(age: movieData.grade)
        downloadMoviePosterImage(url: movieData.thumb)
    }
    private func downloadMoviePosterImage(url: String) {
        
        var image: UIImage?
        let group: DispatchGroup = DispatchGroup()
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async(group: group) {
            
            guard let imageURL: URL = URL(string: url) else { return }
            
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
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self, let image = image else { return }
            
            self.presentMovieImageView.image = image
        }
    }
    private func seperateAgeType(age: Int) {
        guard let type = WatchAge(rawValue: age) else { return }
        
        switch type {
            case .all:
                self.presentMovieAgeImageView.image = UIImage(named: "ic_allages")
            case .twelve:
                self.presentMovieAgeImageView.image = UIImage(named: "ic_12")
            case .fifteen:
                self.presentMovieAgeImageView.image = UIImage(named: "ic_15")
            case .nineteen:
                self.presentMovieAgeImageView.image = UIImage(named: "ic_19")
        }
    }
}
