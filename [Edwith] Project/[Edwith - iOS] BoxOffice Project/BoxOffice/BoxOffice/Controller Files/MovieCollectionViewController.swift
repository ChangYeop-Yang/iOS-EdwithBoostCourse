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
    private var fetchMovieDatas: [MovieList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveMovieDatasNotification), name: NotificationName.moviesListNoti.name, object: nil)

        // MARK: Setting UICollectionView Datasouce
        self.movieCollectionView.dataSource = self
        self.movieCollectionView.delegate   = self
        
        // MARK: Setting UICollectionView FlowLayout
        let flowlayout          = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10)

        self.movieCollectionView.collectionViewLayout = flowlayout
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchMovieCollectionList(type: MOVIE_TYPE)
    }
    
    private func fetchMovieCollectionList(type: Int) {
        
        self.fetchMovieDatas.removeAll()
        self.movieCollectionView.reloadData()
        ShowIndicator.shared.showLoadIndicator(self)
        
        // MARK: Fetch Movie List Datas from Server
        DispatchQueue.global(qos: .unspecified).async {
            ParserMovieJSON.shared.fetchMovieDataParser(type: ParserMovieJSON.MovieParserType.movies.rawValue, subURI: ParserMovieJSON.SubURI.movies.rawValue, parameter: "order_type=\(type)", false)
        }
    }
    @objc private func didReciveMovieDatasNotification(_ noti: Notification) {
        
        guard let result = noti.userInfo![GET_KEY] as? [MovieList] else { return }
        
        self.fetchMovieDatas = result
        
        DispatchQueue.main.async {
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

// MARK: - Extension UICollectionViewDelegateFlowLayout
extension MovieCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 50
        let collectionViewSize = collectionView.frame.size.width - padding

        // MARK: https://stackoverflow.com/questions/38394810/display-just-two-columns-with-multiple-rows-in-a-collectionview-using-storyboar
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 1.2)
    }

}
