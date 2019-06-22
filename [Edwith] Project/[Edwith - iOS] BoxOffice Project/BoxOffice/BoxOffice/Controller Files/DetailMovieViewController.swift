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
    @IBOutlet private weak var movieContentsScrollView:     UIScrollView!
    
    // MARK: - Object Variables
    internal var movieID: String?
    
    private let COMMNET_CELL_HEIGHT: CGFloat = 100
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
        
        ShowIndicator.shared.showLoadIndicator(self)
        
        // MARK: Fetch Movie Detail Information JSON
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movie.rawValue
                , subURI: ParserMovieJSON.SubURI.movie.rawValue
                , parameter: "id=\(id)")
        }
    }
    
    // MARK: - User Methods
    private func setDetailMovieInformation(data: MovieDetailInformation) {
        
        let group: DispatchGroup = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.async(group: group) { [weak self] in
            
            guard let self = self, let audience = self.setNumberFormatter(number: data.audience) else { return }
            
            // MARK: Setting Navigation Bar Title
            self.title = data.title
            
            self.movieTitleLabel.text               = data.title
            self.movieTitleLabel.sizeToFit()
            
            self.movieLaunchLabel.text              = "\(data.date) 개봉"
            self.movieTypeLabel.text                = "\(data.genre) / \(data.duration)분"
            self.movieOutlineLabel.text             = data.synopsis
            self.movieDirectorLabel.text            = data.director
            self.movieActorLable.text               = data.actor
            self.movieReservationRateLabel.text     = String(format: "%d위 %.2f%%", data.reservationGrade ,data.reservationRate)
            self.movieScoreLabel.text               = String(format: "%.2f", data.userRating)
            self.movieWatchPeopleLabel.text         = audience
            
            self.movieRatingView.rating             = data.userRating
            
            seperateAgeType(age: data.grade, imageView: self.movieAgeImageView)
            
            group.leave()
        }
        
        let imageGroup: DispatchGroup = DispatchGroup()
        Networking.shared.downloadImage(url: data.image, group: imageGroup, imageView: self.moviePosterImageView)
        
        group.notify(queue: .global(qos: .userInitiated)) { [weak self] in
            guard let self = self, let id = self.movieID else { return }
            
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.comment.rawValue
                , subURI: ParserMovieJSON.SubURI.comment.rawValue
                , parameter: "movie_id=\(id)")
        }
    }
    
    @objc private func didReciveDetailMovieNotification(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? MovieDetailInformation else { return }
        
        // MARK: 상세 영화 정보를 설정한 후 사용자 댓글 JSON Parsing을 하는 메소드
        setDetailMovieInformation(data: result)
    }
    @objc private func didReciveUserComment(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? Comment else { return }
        
        self.userCommentData.removeAll()
        self.userCommentData = result.comments
        
        ShowIndicator.shared.hideLoadIndicator()
        
        let cellsOfHeight: CGFloat = CGFloat(result.comments.count) * 100
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.movieUserCommentTableView.reloadData()
            self.movieUserCommentTableView.layoutIfNeeded()
            
            let frame = CGRect(x: self.movieUserCommentTableView.frame.origin.x
                , y: self.movieUserCommentTableView.frame.origin.y
                , width: self.movieUserCommentTableView.frame.size.width
                , height: self.movieUserCommentTableView.contentSize.height + cellsOfHeight)

            self.movieUserCommentTableView.frame = frame
            
            
            // MARK: - Setting Dynamic TableView Height
            self.movieContentsScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.movieContentsScrollView.contentSize.height + cellsOfHeight)
//            self.movieContentsScrollView.sizeToFit()
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
        return self.userCommentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifyCell.movieUserCommentCell.rawValue, for: indexPath) as? UserCommentTableViewCell else { return UITableViewCell() }
        
        cell.setUserComment(self.userCommentData[indexPath.row])
        
        return cell
    }
    
}
