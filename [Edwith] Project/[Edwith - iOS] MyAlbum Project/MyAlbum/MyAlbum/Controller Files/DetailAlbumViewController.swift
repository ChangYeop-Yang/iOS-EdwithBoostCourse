//
//  DetailAlbumViewController.swift
//  MyAlbum
//
//  Created by 양창엽 on 19/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Photos

class DetailAlbumViewController: UIViewController {
    
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
        self.albumPhotoCollectionView.delegate   = self
        self.albumPhotoCollectionView.dataSource = self
        setFlowLayoutCollectionView(self.albumPhotoCollectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Fetch Album Photos.
        if let asset = self.receiveFetchPhoto {
            fetchAlbumPhoto(fetch: asset, order: false)
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
    private func fetchAlbumPhoto(fetch: PHAssetCollection, order: Bool) {
        
        self.fetchPhotos.removeAll()
        self.albumPhotoCollectionView.reloadData()
        
        let option      = PhotoManager.photoInstance.getImageFetchOptions(sortingKey: "creationDate", ascending: order)
        let fetchAsset  = PHAsset.fetchAssets(in: fetch, options: option)
        
        for index in 0..<fetchAsset.count {
            PhotoManager.photoInstance.getImageManager().requestImage(for: fetchAsset[index], targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                
                guard let fetchImage: UIImage = image else { return }
                self?.fetchPhotos.append(fetchImage)
            }
        }
    }
    private func showActivityViewController(images: [UIImage]) {
        
        let activityVC = UIActivityViewController(activityItems: [images], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    // MARK: - Action Method
    @IBAction func actionToolBarItem(_ sender: UIBarButtonItem) {
        
        guard let toolbarTag = ToolbarItemTag(rawValue: sender.tag) else { return }
        
        switch toolbarTag {
            case .share: break
                //showActivityViewController(image: <#T##UIImage#>)
            case .order:
                guard let fetch = self.receiveFetchPhoto, let title = sender.title else { return }
            
                let order: Bool = (title == "최신순" ? true : false)
                sender.title    = (title == "최신순" ? "과거순" : "최신순")
                
                fetchAlbumPhoto(fetch: fetch, order: order)
                self.albumPhotoCollectionView.reloadData()
            case .trash: break
            case .select:
                guard let title = sender.title else { return }
            
                // MARK: https://stackoverflow.com/questions/19032940/how-can-i-get-the-ios-7-default-blue-color-programmatically/19033326
                if title == "선택" {
                    sender.title        = "취소"
                    sender.tintColor    = UIColor.red
                } else {
                    sender.title        = "선택"
                    sender.tintColor    = UIButton(type: .system).tintColor
                }
        }
    }
}

// MARK: - Extension UICollectionView DataSource
extension DetailAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IndentifierCell.detailAlbumCell.rawValue, for: indexPath) as? DetailAlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setImageView(image: self.fetchPhotos[indexPath.row])
        
        return cell
    }
}

// MARK: - Extension UICollectionViewDelegate
extension DetailAlbumViewController: UICollectionViewDelegate {
    
}

// MARK: - Extension UICollectionView Delegate FlowLayout
extension DetailAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat    = 45
        let collectionViewSize  = collectionView.frame.size.width - padding
        
        // MARK: https://stackoverflow.com/questions/38394810/display-just-two-columns-with-multiple-rows-in-a-collectionview-using-storyboar
        return CGSize(width: collectionViewSize / 3, height: collectionViewSize / 4)
    }
}
