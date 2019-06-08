//
//  MovieTableViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class MovieTableViewController: UIViewController {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var movieListTableView: UITableView!
    
    // MARK: - Object Variables
    private var fetchMovieDatas: [MovieList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        
        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveMovieDatasNotification), name: NotificationName.listMovies.name, object: nil)
        
        // MARK: Setting TableView DataSource
        self.movieListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchMovieDatas.removeAll()
        self.movieListTableView.reloadData()
        
        // MARK: Fetch Movie List Datas from Server
        ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movies.rawValue, subURI: ParserMovieJSON.SubURI.movies.rawValue, parameter: "order_type=\(MOVIE_TYPE)")
    }
    
    // MARK: - User Method
    private func setNavigationBar() {
        
        self.parent?.title = MovieFetchType.reservation.rawValue
        
        let icon = UIImage(named: "ic_settings")
        
        // MARK: http://swiftdeveloperblog.com/code-examples/uibarbuttonitem-with-image/
        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(showMovieTypeMenu))
    }
    @objc private func didReciveMovieDatasNotification(_ noti: Notification) {
        
        guard let result = noti.userInfo![GET_KEY] as? [MovieList] else { return }
        
        self.fetchMovieDatas = result
        
        DispatchQueue.main.async {
            self.movieListTableView.reloadData()
        }
    }
    
    @objc private func showMovieTypeMenu() {
        showMovieTypeActionSheet(self)
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
