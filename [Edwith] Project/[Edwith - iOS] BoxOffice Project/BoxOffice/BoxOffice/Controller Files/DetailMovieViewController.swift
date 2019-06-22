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
    @IBOutlet private weak var movieRatingView:             RatingStarBar!
    @IBOutlet private weak var movieUserCommentTableView:   UITableView!
    
    // MARK: - Object Variables
    internal var movieID: String?
    private var detailMovieData: MovieDetailInformation?
    private var userCommentData: [MovieOneLineList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self
            , selector: #selector(didReciveDetailMovieNotification)
            , name: NotificationName.movieDetailNoti.name
            , object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(didReciveUserComment)
            , name: NotificationName.movieUserComment.name
            , object: nil)
        
        // MARK: Setting TableView Delegate and Datasource
        self.movieUserCommentTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let id = self.movieID else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movie.rawValue
                , subURI: ParserMovieJSON.SubURI.movie.rawValue
                , parameter: "id=\(id)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.comment.rawValue
                , subURI: ParserMovieJSON.SubURI.comment.rawValue
                , parameter: "movie_id=\(id)")
        }
    }
    
    // MARK: - User Methods
    private func setMovieData(data: MovieDetailInformation) {
        
        // MARK: Setting Outlet
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // MARK: Setting Navigation Bar Title
            self.title = data.title
            
            self.movieTitleLabel.text               = data.title
            self.movieLaunchLabel.text              = "\(data.date) 개봉"
            self.movieTypeLabel.text                = "\(data.genre) / \(data.duration)분"
            self.movieOutlineLabel.text             = data.synopsis
            self.movieDirectorLabel.text            = data.director
            self.movieActorLable.text               = data.actor
            self.movieReservationRateLabel.text     = String(format: "%d위 %.2f%%", data.reservationGrade ,data.reservationRate)
            self.movieScoreLabel.text               = String(format: "%.2f", data.userRating)
            
            self.movieRatingView.rating             = data.userRating
            
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
    @objc private func didReciveUserComment(_ noti: Notification) {
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? Comment else { return }
        
        self.userCommentData = result.comments
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.movieUserCommentTableView.reloadData()
        }
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

// MARK: - Extension UITableViewDataSource
extension DetailMovieViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCommentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifyCell.movieUserCommentCell.rawValue, for: indexPath) as? UserCommentTableViewCell else { return UITableViewCell() }
        
        cell.setUserComment(self.userCommentData[indexPath.row])
        
        return cell
    }
    
}
