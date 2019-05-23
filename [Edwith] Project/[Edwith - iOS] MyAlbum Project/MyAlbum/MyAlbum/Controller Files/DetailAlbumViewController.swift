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
    @IBOutlet private weak var albumPhotoCollectionView:    UICollectionView!
    @IBOutlet private weak var shareToolbarItem:            UIBarButtonItem!
    @IBOutlet private weak var trashToolbarItem:            UIBarButtonItem!
    
    // MARK: - Object Variables
    private var fetchPHAsset:                       [PHAsset]                                       = []
    fileprivate var isSelectedItem:                 Bool                                            = false
    fileprivate var isImageOrder:                   Bool                                            = false
    fileprivate var selectedCollectionViewCell:     Set<DetailAlbumCollectionViewCell>              = []
    internal var receiveFetchPhoto:                 PHAssetCollection?

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
        
        // MARK: PHPhotoLibraryChangeObserver
        PHPhotoLibrary.shared().register(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - User Method
    private func fetchAlbumPhoto(fetch: PHAssetCollection, order: Bool) {
        
        self.fetchPHAsset.removeAll()
        
        let option      = PhotoManager.photoInstance.getImageFetchOptions(sortingKey: "creationDate", ascending: order)
        let fetchAsset  = PHAsset.fetchAssets(in: fetch, options: option)
        
        for index in 0..<fetchAsset.count {
            self.fetchPHAsset.append(fetchAsset[index])
        }
    }
    private func showActivityViewController(cells: Set<DetailAlbumCollectionViewCell>) {
        
        var images: [UIImage] = []
        for cell in cells {
            guard let image = cell.getImages() else { continue }
            images.append(image)
        }
        
        DispatchQueue.main.async { [weak self] in
            let activityVC = UIActivityViewController(activityItems: images as [Any], applicationActivities: nil)
            self?.present(activityVC, animated: true, completion: nil)
        }
        
    }
    private func drawBorderCell(cell: UICollectionViewCell, color: UIColor, width: CGFloat) {
        
        DispatchQueue.main.async {
            cell.layer.borderWidth = width
            cell.layer.borderColor = color.cgColor
        }
    }
    private func fetchImagefromPhotoAsset(asset: PHAsset, size: CGSize) -> UIImage? {
        
        var image: UIImage?
        PhotoManager.photoInstance.getImageManager()
            .requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { img, _ in
                
                guard let fetchImage: UIImage = img else { return }
                image = fetchImage
        }
        
        return image
    }
    private func deleteAlbumPhoto() {
        
        let assets = self.selectedCollectionViewCell.map { $0.getFetchAsset() }
        self.selectedCollectionViewCell.removeAll()
        
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assets as NSArray)
            }, completionHandler: nil)
        }
    }
    
    // MARK: - Action Method
    @IBAction func actionToolBarItem(_ sender: UIBarButtonItem) {
        
        guard let toolbarTag = ToolbarItemTag(rawValue: sender.tag) else { return }
        
        switch toolbarTag {
            case .share:
                if #available(iOS 6, *) {
                    showActivityViewController(cells: self.selectedCollectionViewCell)
                }
            
            case .order:
                guard let fetch = self.receiveFetchPhoto, let title = sender.title else { return }
                
                sender.title      = (title == "최신순" ? "과거순" : "최신순")
                self.isImageOrder = !self.isImageOrder
                
                OperationQueue.main.addOperation { [weak self] in
                    guard let self = self else { return }
                    
                    self.fetchAlbumPhoto(fetch: fetch, order: self.isImageOrder)
                    self.albumPhotoCollectionView.reloadData()
                }
            
            case .trash:
                deleteAlbumPhoto()
            
            case .select:
                guard let title = sender.title else { return }
            
                // MARK: https://stackoverflow.com/questions/19032940/how-can-i-get-the-ios-7-default-blue-color-programmatically/19033326
                if title == "선택" {
                    sender.title        = "취소"
                    sender.tintColor    = UIColor.red
                    self.isSelectedItem = true
                } else {
                    sender.title        = "선택"
                    sender.tintColor    = UIButton(type: .system).tintColor
                    self.isSelectedItem = false
                    
                    // MARK: '취소' 버튼을 누르면 선택된 사진이 해제되고 초기 상태로 되돌아갑니다.
                    for cell in self.selectedCollectionViewCell {
                        drawBorderCell(cell: cell, color: UIColor.white, width: 0)
                    }
                    
                    self.selectedCollectionViewCell.removeAll()
                    self.navigationItem.title = self.receiveFetchPhoto?.localizedTitle
                }
        }
    }
}

// MARK: - Extension UICollectionView DataSource
extension DetailAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchPHAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IndentifierCell.detailAlbumCell.rawValue, for: indexPath) as? DetailAlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let image = fetchImagefromPhotoAsset(asset: self.fetchPHAsset[indexPath.row], size: CGSize(width: 150, height: 150)) {
            cell.setImageView(image: image)
            cell.setFetchAsset(asset: self.fetchPHAsset[indexPath.row])
        }
        
        return cell
    }
}

// MARK: - Extension UICollectionViewDelegate
extension DetailAlbumViewController: UICollectionViewDelegate {
    
    // MARK: collectionView(_:didSelectItemAt:) : 지정된 셀이 선택되었음을 알리는 메서드.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // MARK: Enable Select Mode. (Delete, Share)
        if self.isSelectedItem, let cell = collectionView.cellForItem(at: indexPath) as? DetailAlbumCollectionViewCell {
            
            // MARK: 선택 된 셀이 다시 선택이 된 경우 (Release)
            if self.selectedCollectionViewCell.contains(cell) {
                self.selectedCollectionViewCell.remove(cell)
                self.drawBorderCell(cell: cell, color: UIColor.white, width: 0)
            }
            // MARK: 선택 되지 않은 셀이 선택 된 경우 (Lock)
            else {
                self.selectedCollectionViewCell.insert(cell)
                self.drawBorderCell(cell: cell, color: UIColor.darkGray, width: 3)
            }
            
            // MARK: 선택된 사진 장수가 내비게이션 아이템의 타이틀에 즉각 반영됩니다.
            self.navigationItem.title = "\(self.selectedCollectionViewCell.count)장 선택"
            
            // MARK: 사진이 선택 모드에 들어가 선택된 사진이 1장 이상일 때만 활성화됩니다.
            let isEnabled = self.selectedCollectionViewCell.count > 0 ? true : false
            self.shareToolbarItem.isEnabled = isEnabled
            self.trashToolbarItem.isEnabled = isEnabled
        }
    }
    
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

// MARK: - Extension PHPhotoLibraryChange Observer
extension DetailAlbumViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        OperationQueue.main.addOperation { [weak self] in
            
            guard let self = self, let fetch = self.receiveFetchPhoto else { return }
            
            self.fetchAlbumPhoto(fetch: fetch, order: self.isImageOrder)
            self.albumPhotoCollectionView.reloadData()
        }
    }
}
