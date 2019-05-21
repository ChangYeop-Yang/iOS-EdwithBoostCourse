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
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var userAlbumCollectionView: UICollectionView!
    
    // MARK: - Object Variables
    fileprivate var fetchAlbumResult:       [PHResult]                  = []
    fileprivate var fetchCollectionResult:  [PHAssetCollection]         = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // MARK: UICollectionView DataSource
        setCollectionView()
        
        // MARK: Request Photos Autorization
        askPhotosAuthorization()
        
        // MARK: https://stackoverflow.com/questions/5277940/why-does-viewwillappear-not-get-called-when-an-app-comes-back-from-the-backgroun
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // MARK: https://stackoverflow.com/questions/31914213/how-to-make-prepareforsegue-with-uicollectionview
        guard let detailAlbumVC = segue.destination as? DetailAlbumViewController
            , let cell = sender as? RepresentAlbumCollectionViewCell else {
            return
        }
        
        if let selectedCellRow = self.userAlbumCollectionView.indexPath(for: cell)?.row {
            detailAlbumVC.receiveFetchPhoto = self.fetchCollectionResult[selectedCellRow]
        }
    }
    
    // MARK: - Notification Method
    @objc private func willEnterForeground() {
        
        // MARK: Check Photos Aurhorization
        askPhotosAuthorization()
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
                    self?.fetchCollectionResult.append(collection)
                }
            }
            
        }
        
        OperationQueue.main.addOperation { [weak self] in
            self?.userAlbumCollectionView.reloadData()
        }
    }
    private func setCollectionView() {
        
        // MARK: CollectionView DataSource and Delegate
        self.userAlbumCollectionView.delegate   = self
        self.userAlbumCollectionView.dataSource = self
        
        // MARK: Set Flowlayout
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10)
        self.userAlbumCollectionView.collectionViewLayout = flowlayout
    }
    private func askPhotosAuthorization() {
        
        let title = "‼️ Error, Disabled Photos Permission"
        let message = "MyAlbum 애플리케이션을 사용하기 위해서는 Photos 사용 권한이 필요합니다."
        
        // MARK: 애플리케이션 처음 진입 시 사진 라이브러리 접근권한이 없다면 사진 라이브러리에 접근 허용 여부를 묻습니다.
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
                case .authorized:
                    self?.requestPhotoCollection()
                case .denied, .restricted:
                    self?.showAlert(title: title, message: message, style: .alert)
                default: break
            }
        }
        
    }
    private func showAlert(title: String, message: String, style: UIAlertController.Style) {
        
        DispatchQueue.main.async { [weak self] in
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(confirmAction)
            
            self?.present(alertController, animated: true, completion: nil)
            
        }
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
