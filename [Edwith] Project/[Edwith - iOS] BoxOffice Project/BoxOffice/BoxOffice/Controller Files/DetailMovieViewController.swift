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
        
        self.navigationItem.rightBarButtonItem = createReloadNavigationItem()
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
        
        DispatchQueue.main.async { [weak self] in
        
            // 영화 포스터를 터치하면 포스터를 전체화면에서 볼 수 있습니다.            
            let storyboard = UIStoryboard(name: "ModalMoviePoster", bundle: nil)
            
            // 😃 생각해보기: 유저의 입장에서는 영화 포스터를 터치하여 크게 보는 기능은 은 작품 상세 화면이 아닌 또다른 화면을 모달형식으로 노출하는 보편적인 UI를 생각할 것 같습니다 (Edwith - jiyeonpark)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "ModalMoviePosterVC") as? FullMoviePosterViewController else { return }
            
            controller.modalPresentationStyle = .fullScreen
            controller.image = image

            self?.present(controller, animated: true, completion: nil)
        }
    }
    func createReloadNavigationItem() -> UIBarButtonItem {
        
        let reload = UIBarButtonItem.init(title: "새로고침"
            , style: .plain
            , target: self
            , action: #selector(self.reloadMovieUserComment))
        
        return reload
    }
    func fetchMovieUserComments() {
        
        guard let result = self.detailMovieData else { return }
        
        // https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1.5) {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.comment.rawValue
                , subURI: ParserMovieJSON.SubURI.comment.rawValue
                , parameter: "movie_id=\(result.id)")
        }
    }
    
    @objc func reloadMovieUserComment() {
        
        ShowIndicator.shared.showLoadIndicator(self)
        
        fetchMovieUserComments()
    }
    @objc func didReciveDetailMovieNotification(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? MovieDetailInformation else { return }
        
        // MARK: 상세 영화 정보를 설정한 후 사용자 댓글 JSON Parsing을 하는 메소드
        self.detailMovieData = result
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 😀 생각해 보기: 프로젝트 구성이 아래와같이 설계되었기 때문에 네비게이션 바에 타이틀과 버튼을 넣기 위해 self.parent?.title이 아닌 self.navigationItem.title 을 사용하여야합니다. (Edwith - jiyeonpark)
            self.navigationItem.title = result.title
            self.tableView.reloadData()
        }
        
        fetchMovieUserComments()
    }
    @objc func didReciveUserComment(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let result = receive[GET_KEY] as? Comment else { return }
        
        ShowIndicator.shared.hideLoadIndicator()
    
        self.userCommentData.removeAll(keepingCapacity: false)
        self.userCommentData = result.comments
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            
            // https://gogorchg.tistory.com/entry/iOS-UITableView-scroll-to-top
            let indexPath = IndexPath(row: NSNotFound, section: 0)
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
               
                //cell.clearCellSubview()
                if self.userCommentData.isEmpty == false {
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
        guard let image = imageView.image else { return }
        
        showMoviePosterFullScreen(image: image)
    }
}
