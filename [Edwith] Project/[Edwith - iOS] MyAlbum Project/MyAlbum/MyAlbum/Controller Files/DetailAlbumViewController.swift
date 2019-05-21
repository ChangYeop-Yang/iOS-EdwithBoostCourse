//
//  DetailAlbumViewController.swift
//  MyAlbum
//
//  Created by 양창엽 on 19/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Photos

class DetailAlbumViewController: UICollectionViewController {
    
    // MARK: - Enum
    private enum ToolbarItemTag: Int {
        case share  = 100
        case order  = 200
        case trash  = 300
        case select = 400
    }
    
    // MARK: - Outlet Variables
    @IBOutlet private var albumPhotoCollectionView: UICollectionView!
    
    // MARK: - Object Variables
    private var fetchPhotos:        [UIImage] = []
    internal var receiveFetchPhoto: PHAssetCollection?

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: UICollectionView Delegate and Datasource
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Fetch Album Photos.
        if let asset = self.receiveFetchPhoto {
            fetchAlbumPhoto(fetch: asset, order: true)
        }
        
        // MARK: Set Navigation Title and Toolbar
        self.title = self.receiveFetchPhoto?.localizedTitle
        self.navigationController?.isToolbarHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - User Method
    private func setCollectionView() {
        
        self.albumPhotoCollectionView.delegate   = self
        self.albumPhotoCollectionView.dataSource = self
        
        // MARK: Set Flowlayout
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10)
        self.albumPhotoCollectionView.collectionViewLayout = flowlayout
    }
    private func fetchAlbumPhoto(fetch: PHAssetCollection, order: Bool) {
        
        self.fetchPhotos.removeAll()
        
        let option      = PhotoManager.photoInstance.getImageFetchOptions(sortingKey: "creationDate", ascending: order)
        let fetchAsset  = PHAsset.fetchAssets(in: fetch, options: option)
        
        for index in 0..<fetchAsset.count {
            PhotoManager.photoInstance.getImageManager().requestImage(for: fetchAsset[index], targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                
                guard let fetchImage: UIImage = image else { return }
                self?.fetchPhotos.append(fetchImage)
            }
        }
    }
    
    // MARK: - UICollectionView Datasource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IndentifierCell.detailAlbumCell.rawValue, for: indexPath) as? DetailAlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setImageView(image: self.fetchPhotos[indexPath.row])
        
        return cell
    }

}

// MARK: - Extension UICollectionViewDelegateFlowLayout
extension DetailAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat    = 45
        let collectionViewSize  = collectionView.frame.size.width - padding
        
        // MARK: https://stackoverflow.com/questions/38394810/display-just-two-columns-with-multiple-rows-in-a-collectionview-using-storyboar
        return CGSize(width: collectionViewSize / 3, height: collectionViewSize / 4)
    }
}
