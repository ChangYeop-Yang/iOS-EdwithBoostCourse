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
    
    // MARK: - Object Variables
    private var fetchMovieDatas: [MovieList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
    }
    
    // MARK: - User Method
    private func setNavigationBar() {
        
        self.parent?.title = MovieFetchType.reservation.rawValue
        
        let icon = UIImage(named: "ic_settings")
        
        // MARK: http://swiftdeveloperblog.com/code-examples/uibarbuttonitem-with-image/
        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(showMovieTypeMenu))
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
