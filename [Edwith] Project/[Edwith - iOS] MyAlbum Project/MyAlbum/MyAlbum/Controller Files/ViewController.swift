//
//  ViewController.swift
//  MyAlbum
//
//  Created by 양창엽 on 18/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    // MARK: - Typealias
    fileprivate typealias PHResult = (title: String, asset: PHFetchResult<PHAsset>)
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var userAlbumCollectionView: UICollectionView!
    
    // MARK: - Object Variables
    fileprivate var fetchAlbumResult: [PHResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // MARK: UICollectionView DataSource
        setCollectionView()
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized { self.requestPhotoCollection() }
        }
        
//        // MARK: Check Photos Aurhorization
//        if PhotoManager.photoInstance.getAurhorizationPhotosState(parent: self) {
//            requestPhotoCollection()
//        }
        
        // MARK: Set Notification (https://stackoverflow.com/questions/5277940/why-does-viewwillappear-not-get-called-when-an-app-comes-back-from-the-backgroun)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Notification Method
    @objc func willEnterForeground() {
        
        // MARK: Check Photos Aurhorization
        if PhotoManager.photoInstance.getAurhorizationPhotosState(parent: self) {
            requestPhotoCollection()
        }
    }
    
    // MARK: - User Method
    private func requestPhotoCollection() {
        
        // MARK: Delete All Objects
        self.fetchAlbumResult.removeAll()
        
        // MARK: Camera Album 사진 콜렉션을 가져온다.
        let fetchOption = PhotoManager.photoInstance.getImageFetchOptions(sortingKey: "creationDate", ascending: true)
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        cameraRoll.enumerateObjects { [weak self] collection, _, _ in
            
            let photoInAlbum = PHAsset.fetchAssets(in: collection, options: fetchOption)
            
            // MARK: Album에 포함 된 사진의 수가 1장 이상인 경우에만 추가한다.
            if photoInAlbum.count > 0 {
                if let title = collection.localizedTitle {
                    let fetch = PHResult(title, photoInAlbum)
                    self?.fetchAlbumResult.append(fetch)
                }
            }
            
        }
        
        OperationQueue.main.addOperation { [weak self] in
            self?.userAlbumCollectionView.reloadData()
        }
    }
    private func setCollectionView() {
        
        // MARK: CollectionView DataSource and Delegate
        self.userAlbumCollectionView.delegate = self
        self.userAlbumCollectionView.dataSource = self
        
        // MARK: Set Flowlayout
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10)
        self.userAlbumCollectionView.collectionViewLayout = flowlayout
    }
}

// MARK: - Extension UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchAlbumResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IndentifierCell.repersentAlbumCell.rawValue, for: indexPath) as? RepresentAlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // MARK: Get Represent Album Image
        let fetchResult = self.fetchAlbumResult[indexPath.row].asset
        
        if let representImage = fetchResult.firstObject {
            PhotoManager.photoInstance.getImageManager()
                .requestImage(for: representImage, targetSize: cell.getImageViewSize(), contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                
                guard let photoAsset = image, let photoTitle = self?.fetchAlbumResult[indexPath.row].title else { return }
                cell.setRepresentPhotoOutlets(image: photoAsset, title: photoTitle, count: fetchResult.count)
            }
        }
        
        return cell
    }
    
}

// MARK: - Extension UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat =  35
        let collectionViewSize = collectionView.frame.size.width - padding
        
        // MARK: https://stackoverflow.com/questions/38394810/display-just-two-columns-with-multiple-rows-in-a-collectionview-using-storyboar
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2)
    }
    
}
