//
//  MovieTableViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class MovieTableViewController: UIViewController {
    
    // MARK: - Outlet Propertise
    @IBOutlet private weak var movieListTableView: UITableView!
    
    // MARK: - Object Propertise
    private var fetchMovieDatas: [MovieList] = []
    private var refreshControl: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Setting NavigationBar
        setNavigationBar()
        
        // MARK: Change Movie Type Observer Delegate
        TargetAction.shared.delegate = self
        
        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveMovieDatasNotification), name: NotificationName.moviesListNoti.name, object: nil)
        
        // MARK: Setting TableView
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Dynamic TableView Cell Height.
        self.movieListTableView.rowHeight = UITableView.automaticDimension
        self.movieListTableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: Fetch Movie List From JSON Server
        fetchTableMovieList(type: MOVIE_TYPE)
    }
    
    // MARK: - System Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 테이블뷰/컬렉션뷰의 셀을 누르면 해당 영화의 상세 정보를 보여주는 화면 2로 전환합니다.
        guard let controller = segue.destination as? DetailMovieViewController else { return }
        
        guard let indexPath = self.movieListTableView.indexPathForSelectedRow else { return }
        
        controller.movieID = self.fetchMovieDatas[indexPath.row].id
    }
}

// MARK: - MovieTableViewController
private extension MovieTableViewController {
    
    private func setTableView() {
        
        // MARK: Setting TableView DataSource and Delegate
        self.movieListTableView.delegate    = self
        self.movieListTableView.dataSource  = self
        
        // MARK: https://developer.apple.com/documentation/uikit/uirefreshcontrol
        if #available(iOS 6.0, *) {
            self.movieListTableView.refreshControl = self.refreshControl
        } else {
            self.movieListTableView.addSubview(self.refreshControl)
        }
        
        // MARK: https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
        self.refreshControl.tintColor = .systemColor
        self.refreshControl.attributedTitle = NSAttributedString(string: "Just a moment...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemColor])
        
        refreshControl.addTarget(self, action: #selector(refreshTableViewDatas), for: .valueChanged)
    }
    private func setNavigationBar() {
        
        self.parent?.title = MovieFetchType.reservation.rawValue
        
        let icon = UIImage(named: "ic_settings")
        
        // MARK: http://swiftdeveloperblog.com/code-examples/uibarbuttonitem-with-image/
        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(showMovieTypeMenu))
    }
    private func fetchTableMovieList(type: Int) {
        
        // MARK: Remove All Datas
        self.fetchMovieDatas.removeAll()
        self.movieListTableView.reloadData()
        
        ShowIndicator.shared.showLoadIndicator(self)
        
        // MARK: Fetch Movie List Datas from Server
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movies.rawValue, subURI: ParserMovieJSON.SubURI.movies.rawValue, parameter: "order_type=\(type)")
        }
    }
    
    @objc private func refreshTableViewDatas() {
        
        fetchTableMovieList(type: MOVIE_TYPE)
        
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    @objc private func didReciveMovieDatasNotification(_ noti: Notification) {
        
        guard let result = noti.userInfo![GET_KEY] as? [MovieList] else { return }
        
        self.fetchMovieDatas = result
        ShowIndicator.shared.hideLoadIndicator()
        
        DispatchQueue.main.async { [weak self] in
            self?.movieListTableView.reloadData()
        }
    }
    @objc private func showMovieTypeMenu() {
        TargetAction.shared.showMovieTypeActionSheet(self)
    }
}

// MARK: - Extension UITableViewDataSource
extension MovieTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchMovieDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifyCell.movieCell.rawValue, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setPresentMovieData(movieData: self.fetchMovieDatas[indexPath.row])
        
        return cell
    }
}

// MARK: - Extension UITableViewDelegate
extension MovieTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SizeCellHeight.movie.rawValue
    }
}

// MARK: - Extension MovieTypeDelegate
extension MovieTableViewController: MovieTypeDelegate {
    func changeMovieTypeEvent() {
        // MARK: Fetch Movie List From JSON Server
        fetchTableMovieList(type: MOVIE_TYPE)
    }
}
