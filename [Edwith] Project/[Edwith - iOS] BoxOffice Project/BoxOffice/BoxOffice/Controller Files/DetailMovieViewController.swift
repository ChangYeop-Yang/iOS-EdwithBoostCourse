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
    @IBOutlet private weak var movieRatingView:             StarRatingBar!
    @IBOutlet private weak var movieUserCommentTableView:   UITableView!
    @IBOutlet private weak var movieContentsScrollView:     UIScrollView!
    
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
        self.movieUserCommentTableView.delegate             = self
        self.movieUserCommentTableView.dataSource           = self
        self.movieUserCommentTableView.estimatedRowHeight   = SizeCellHeight.comment.rawValue
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let id = self.movieID else { return }
        
        ShowIndicator.shared.showLoadIndicator(self)
        
        // MARK: Fetch Movie Detail Information JSON
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movie.rawValue
                , subURI: ParserMovieJSON.SubURI.movie.rawValue
                , parameter: "id=\(id)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let controller = segue.destination as? UserCommentViewController else { return }
        
        guard let information = self.detailMovieData else { return }
    
        controller.informationMovie = (information.title, information.id, information.grade)
    }
    
    // MARK: - User Method
    private func setDetailMovieInformation(data: MovieDetailInformation) {
        
        let group: DispatchGroup = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.async(group: group) { [weak self] in
            
            guard let self = self, let audience = self.setNumberFormatter(number: data.audience) else { return }
            
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
            self.movieWatchPeopleLabel.text         = audience
            
            self.movieRatingView.score              = CGFloat(data.userRating) / 2.0
            
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
    private func setNumberFormatter(number: Int) -> String? {
        
        let numeric: NSNumber = NSNumber(value: number)
        
        let formatter: NumberFormatter  = NumberFormatter()
        formatter.groupingSeparator     = ","
        formatter.numberStyle           = .decimal
        
        if let result: String = formatter.string(from: numeric) { return result }
        else { return nil }
    }
    
    @objc private func didReciveDetailMovieNotification(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? MovieDetailInformation else { return }
        
        // MARK: 상세 영화 정보를 설정한 후 사용자 댓글 JSON Parsing을 하는 메소드
        self.detailMovieData = result
        setDetailMovieInformation(data: result)
    }
    @objc private func didReciveUserComment(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? Comment else { return }
        
        self.userCommentData.removeAll()
        self.userCommentData = result.comments
        
        ShowIndicator.shared.hideLoadIndicator()
                
        let cellsOfHeight: CGFloat = CGFloat(result.comments.count) * SizeCellHeight.comment.rawValue
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.movieUserCommentTableView.reloadData()

            // MARK: Setting Dynamic TableView Height
            var frame: CGRect = self.movieUserCommentTableView.frame
            frame.size.height = self.movieUserCommentTableView.contentSize.height
            self.movieUserCommentTableView.frame = frame
            
            // MARK: SEtting Dynamic ScrollView Height
            self.movieContentsScrollView.layoutIfNeeded()
            self.movieContentsScrollView.contentSize = CGSize(width: self.view.frame.width
                , height: self.movieContentsScrollView.contentSize.height + cellsOfHeight)
        }
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

// MARK: - Extension UITableViewDelegate
extension DetailMovieViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SizeCellHeight.comment.rawValue;
    }
}
