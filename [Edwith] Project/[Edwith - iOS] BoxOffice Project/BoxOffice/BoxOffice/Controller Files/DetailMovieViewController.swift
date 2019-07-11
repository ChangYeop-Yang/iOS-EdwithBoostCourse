//
//  DetailMovieViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 12/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//
import UIKit

class DetailMovieViewController: UITableViewController {
    
    // MARK: - Enum
    private enum SectionIndexPath: Int {
        case detail     = 0
        case outline    = 1
        case people     = 2
        case write      = 3
        case comment    = 4
    }
    
    // MARK: - Object Propertise
    internal var movieID: String?
    private var moviePosterImage: UIImage?
    private var fullScreenMoviePoster: UIImageView?
    private var detailMovieData: MovieDetailInformation?
    private var userCommentData: [MovieOneLineList] = []
    
    // MARK: - Life Cycle
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Dynamic UITableViewController Static Cell Height.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
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
    
    // MARK: - System Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let controller = segue.destination as? UserCommentViewController else { return }
        
        guard let information = self.detailMovieData else { return }
        
        controller.informationMovie = (information.title, information.id, information.grade)
    }
}

// MARK: - Extension DetailMovieViewController
private extension DetailMovieViewController {
    
    func showMoviePosterFullScreen(image: UIImage) {
        
        // 영화 포스트가 전체 화면인 경우에는 포스트를 제거한다.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
        
            // 영화 포스터를 터치하면 포스터를 전체화면에서 볼 수 있습니다.
            let imageView = UIImageView(image: image)
            imageView.frame = self.view.bounds
            imageView.contentMode = .scaleToFill
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.addSubview(imageView)
            self.fullScreenMoviePoster = imageView
            
            // 영화 포스터 종료 네비게이션 버튼
            let close = UIBarButtonItem.init(title: "닫기"
                , style: .plain
                , target: self
                , action: #selector(self.closeMoviePosterScreen))
            self.navigationItem.rightBarButtonItem = close
        }
    }
    @objc func closeMoviePosterScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.fullScreenMoviePoster != nil else { return }

            // https://stackoverflow.com/questions/26028455/gesturerecognizer-not-responding-to-tap
            self.fullScreenMoviePoster?.removeFromSuperview()
            self.fullScreenMoviePoster = nil

            self.navigationItem.rightBarButtonItem = nil
        }
    }
    @objc func didReciveDetailMovieNotification(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? MovieDetailInformation else { return }
        
        // MARK: 상세 영화 정보를 설정한 후 사용자 댓글 JSON Parsing을 하는 메소드
        self.detailMovieData = result
        
        OperationQueue.main.addOperation { [weak self] in
            self?.title = result.title
            self?.tableView.reloadData()
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.comment.rawValue
                , subURI: ParserMovieJSON.SubURI.comment.rawValue
                , parameter: "movie_id=\(result.id)")
        }
    }
    @objc func didReciveUserComment(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? Comment else { return }
        
        ShowIndicator.shared.hideLoadIndicator()
        
        self.userCommentData.removeAll(keepingCapacity: false)
        self.userCommentData = result.comments
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - Extension UITableView Delegate And DataSource
internal extension DetailMovieViewController {
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - UITableView Datasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == SectionIndexPath.detail.rawValue || section == SectionIndexPath.comment.rawValue {
            return nil
        } else {
            return " "
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == SectionIndexPath.comment.rawValue ? self.userCommentData.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let basicCell = UITableViewCell()
        
        guard let section = SectionIndexPath(rawValue: indexPath.section), let data = self.detailMovieData else {
            return basicCell
        }
        
        switch section {
            
            case .detail:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTopTableViewCell", for: indexPath) as? DetailTopTableViewCell else { return basicCell }
                
                cell.delegate = self
                cell.setMovieDetailViews(data)
                return cell
                
            case .outline:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailOutlineCell", for: indexPath) as? DetailOutlineCell else { return basicCell }
                
                cell.setMovieOutlineView(data.synopsis)
                return cell
                
            case .people:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActorAndDirectorCell", for: indexPath) as? DetailActorAndDirectorCell else { return basicCell }
                
                cell.setActorAndDirectorView(actor: data.actor, director: data.director)
                return cell
                
            case .write:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailWriteCell", for: indexPath) as? DetailWriteCell else { return basicCell }
                return cell
                
            case .comment:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCommentViewCell", for: indexPath) as? UserCommentViewCell else { return basicCell }
                
                if !self.userCommentData.isEmpty {
                    cell.movieID = data.id
                    cell.setUserComment(self.userCommentData[indexPath.row])
                }
                
                return cell
        }
    }
}

// MARK: - Extension FullScreenPosterGesture Delegate
extension DetailMovieViewController: FullScreenPosterGesture {
    
    func showFullScreenMoviePoster(imageView: UIImageView) {
        guard let image = imageView.image, self.fullScreenMoviePoster == nil else { return }
        
        showMoviePosterFullScreen(image: image)
    }
}
