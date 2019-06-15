//
//  DetailMovieViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 12/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailMovieViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet private weak var moviePosterImageView:        UIImageView!
    @IBOutlet private weak var movieAgeImageView:           UIImageView!
    @IBOutlet private weak var movieTitleLabel:             UILabel!
    @IBOutlet private weak var movieLaunchLabel:            UILabel!
    @IBOutlet private weak var movieTypeLabel:              UILabel!
    @IBOutlet private weak var movieOutlineLabel:           UILabel!
    @IBOutlet private weak var movieActorLable:             UILabel!
    @IBOutlet private weak var movieDirectorLabel:          UILabel!
    @IBOutlet private weak var movieReservationRateLabel:   UILabel!
    @IBOutlet private weak var movieScoreLabel:             UILabel!
    @IBOutlet private weak var movieWatchPeopleLabel:       UILabel!
    
    // MARK: - Object Variables
    internal var movieID: String?
    private var detailMovieData: MovieDetailInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveDetailMovieNotification), name: NotificationName.movieDetailNoti.name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let id = self.movieID else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movie.rawValue, subURI: ParserMovieJSON.SubURI.movie.rawValue, parameter: "id=\(id)")
        }
    }
    
    // MARK: - User Methods
    private func setMovieData(data: MovieDetailInformation) {
        
        // MARK: Setting Navigation Bar Title
        self.title = data.title
        
        // MARK: Setting Outlet
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.movieTitleLabel.text               = data.title
            self.movieLaunchLabel.text              = "\(data.date) 개봉"
            self.movieTypeLabel.text                = "\(data.genre) / \(data.duration)분"
            self.movieOutlineLabel.text             = data.synopsis
            self.movieDirectorLabel.text            = data.director
            self.movieActorLable.text               = data.actor
            self.movieReservationRateLabel.text     = String(format: "%d위 %.2f%%", data.reservationGrade ,data.reservationRate)
            self.movieScoreLabel.text               = String(format: "%.2f", data.userRating)
            
            if let audience = self.setNumberFormatter(number: data.audience) {
                self.movieWatchPeopleLabel.text = audience
            }
        }
        
        let group: DispatchGroup = DispatchGroup()
        Networking.shared.downloadImage(url: data.image, group: group, imageView: self.moviePosterImageView)
    }
    @objc private func didReciveDetailMovieNotification(_ noti: Notification) {
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? MovieDetailInformation else { return }
        
        setMovieData(data: result)
    }
    private func setNumberFormatter(number: Int) -> String? {
        
        let numeric: NSNumber = NSNumber(value: number)
        
        let formatter: NumberFormatter  = NumberFormatter()
        formatter.groupingSeparator     = ","
        formatter.numberStyle           = .decimal    
        
        if let result: String = formatter.string(from: numeric) { return result }
        else { return nil }
    }
}
