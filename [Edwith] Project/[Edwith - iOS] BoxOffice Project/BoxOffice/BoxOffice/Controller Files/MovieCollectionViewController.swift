//
//  MovieCollectionViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class MovieCollectionViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet private weak var movieCollectionView: UICollectionView!
    
    // MARK: - Object Variables
    private var fetchMovieDatas:    [MovieList]         = []
    private var refreshControl:     UIRefreshControl    = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveMovieDatasNotification), name: NotificationName.moviesListNoti.name, object: nil)

        // MARK: Setting UICollectionView
        setCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchMovieCollectionList(type: MOVIE_TYPE)
    }
    
    private func setCollectionView() {
        
        // MARK: Setting UICollectionView Datasouce
        self.movieCollectionView.dataSource = self
        
        self.movieCollectionView.alwaysBounceVertical = true
        
        // MARK: https://developer.apple.com/documentation/uikit/uirefreshcontrol
        if #available(iOS 6.0, *) {
            self.movieCollectionView.refreshControl = self.refreshControl
        } else {
            self.movieCollectionView.addSubview(self.refreshControl)
        }
        
        // MARK: https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
        self.refreshControl.tintColor = .orange
        self.refreshControl.attributedTitle = NSAttributedString(string: "Just a moment...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.orange])
        
        self.refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        
        // MARK: Setting Flowlayout 
        if let layout = self.movieCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let value: (divide: CGFloat, span: CGFloat, revision: CGFloat) = (2, 20, 100)
            let width: CGFloat = (self.view.frame.width - value.span) / value.divide
            
            layout.itemSize = CGSize(width: width, height: width + value.revision)
        }
    }
    private func fetchMovieCollectionList(type: Int) {
        
        self.fetchMovieDatas.removeAll()
        self.movieCollectionView.reloadData()
        
        ShowIndicator.shared.showLoadIndicator(self)
        
        // MARK: Fetch Movie List Datas from Server
        DispatchQueue.global(qos: .userInitiated).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movies.rawValue, subURI: ParserMovieJSON.SubURI.movies.rawValue, parameter: "order_type=\(type)")
        }
    }
    @objc private func refreshCollectionView() {
        
        fetchMovieCollectionList(type: MOVIE_TYPE)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
        }
    }
    @objc private func didReciveMovieDatasNotification(_ noti: Notification) {
        
        guard let result = noti.userInfo![GET_KEY] as? [MovieList] else { return }
        
        self.fetchMovieDatas = result
        
        ShowIndicator.shared.hideLoadIndicator()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.movieCollectionView.reloadData()
        }
    }
}

// MARK: - Extension UICollectionView Data Source
extension MovieCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchMovieDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifyCell.movieCollecionCell.rawValue, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setMovieCollectionViewCell(movieData: self.fetchMovieDatas[indexPath.row])
        
        return cell
    }
}
