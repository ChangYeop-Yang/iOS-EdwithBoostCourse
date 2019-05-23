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
    @IBOutlet private weak var selectRightBarItem:          UIBarButtonItem!
    @IBOutlet private weak var orderToolbarItem:            UIBarButtonItem!
    
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
    
    // MARK: - User Method
    private func fetchAlbumPhoto(fetch: PHAssetCollection, order: Bool) {
        
        self.fetchPHAsset.removeAll()
        
        let option      = PhotoManager.photoInstance.getImageFetchOptions(sortingKey: "creationDate", ascending: order)
        let fetchAsset  = PHAsset.fetchAssets(in: fetch, options: option)
        
        for index in 0..<fetchAsset.count {
            self.fetchPHAsset.append(fetchAsset[index])
        }
    }
    private func drawBorderCell(cell: DetailAlbumCollectionViewCell, color: UIColor, width: CGFloat) {
        DispatchQueue.main.async {
            cell.layer.borderWidth = width
            cell.layer.borderColor = color.cgColor
            // MARK: borderColor == White -> Clear / borderColor == Gray -> LightGray
            cell.getFrontCoverView().backgroundColor = (color == UIColor.white ? UIColor.clear : UIColor.init(white: 0.5, alpha: 0.3))
        }
    }
    private func deleteAlbumPhoto(sender: UIBarButtonItem) {
        
        let assets = self.selectedCollectionViewCell.map { $0.getFetchAsset() }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }, completionHandler: { [weak self] _, _ in
            
            guard let self = self else { return }
            
            self.selectAlbumPhoto(sender: sender)
            
            DispatchQueue.main.async { [weak self] in
                self?.shareToolbarItem.isEnabled = false
                self?.trashToolbarItem.isEnabled = false
            }
        })
    }
    private func selectAlbumPhoto(sender: UIBarButtonItem) {
        
        guard let title = sender.title else { return }
        
        // MARK: https://stackoverflow.com/questions/19032940/how-can-i-get-the-ios-7-default-blue-color-programmatically/19033326
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if title == "선택" {
                sender.title                    = "취소"
                sender.tintColor                = UIColor.red
                self.isSelectedItem             = true
                self.orderToolbarItem.isEnabled = false
            } else {
                sender.title                    = "선택"
                sender.tintColor                = UIButton(type: .system).tintColor
                self.isSelectedItem             = false
                
                // MARK: '취소' 버튼을 누르면 선택된 사진이 해제되고 초기 상태로 되돌아갑니다.
                for cell in self.selectedCollectionViewCell {
                    self.drawBorderCell(cell: cell, color: UIColor.white, width: 0)
                }
                
                self.selectedCollectionViewCell.removeAll()
                self.navigationItem.title       = self.receiveFetchPhoto?.localizedTitle
                
                // MARK: Set Enabled Toolbar and Navigationbar Buttons
                self.orderToolbarItem.isEnabled = true
                self.shareToolbarItem.isEnabled = false
                self.trashToolbarItem.isEnabled = false
            }
        }
    }
    private func orderAlbumPhoto(sender: UIBarButtonItem) {
        
        guard let fetch = self.receiveFetchPhoto, let title = sender.title else { return }
        
        sender.title      = (title == "최신순" ? "과거순" : "최신순")
        self.isImageOrder = !self.isImageOrder
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.fetchAlbumPhoto(fetch: fetch, order: self.isImageOrder)
            self.albumPhotoCollectionView.reloadData()
        }
    }
    private func shareAlbumPhoto() {
        
        if #available(iOS 6, *) {
            let images = self.selectedCollectionViewCell.map { $0.getImages() }
            DispatchQueue.main.async { [weak self] in
                let activityVC = UIActivityViewController(activityItems: images as [Any], applicationActivities: nil)
                self?.present(activityVC, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                
                let alertVC = UIAlertController(title: "Error, Not Support iOS Version", message: "iOS 6.0 이하 버전은 해당 기능을 사용할 수 없습니다.", preferredStyle: .alert)
                
                let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertVC.addAction(confirm)
                
                self?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    private func showStoryboard(indexPath: IndexPath, group: DispatchGroup) {
        
        var controller: UIViewController?
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async(group: group) {
            // MARK: https://stackoverflow.com/questions/39929592/how-to-push-and-present-to-uiviewcontroller-programmatically-without-segue-in-io
            let storyboard = UIStoryboard(name: IdentifierStoryboard.detailPhoto.rawValue, bundle: nil)
            controller = storyboard.instantiateViewController(withIdentifier: IdentifierViewController.detailPhoto.rawValue)
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self, let detailPhotoVC = controller as? DetailPictureViewController else {
                return
            }
            
            detailPhotoVC.photoAsset = self.fetchPHAsset[indexPath.row]
            self.navigationController?.pushViewController(detailPhotoVC, animated: true)
        }
    }
    
    // MARK: - Action Method
    @IBAction func actionToolBarItem(_ sender: UIBarButtonItem) {
        
        guard let toolbarTag = ToolbarItemTag(rawValue: sender.tag) else { return }
        
        switch toolbarTag {
            case .share:
                shareAlbumPhoto()
            
            case .order:
                orderAlbumPhoto(sender: sender)
            
            case .trash:
                deleteAlbumPhoto(sender: self.selectRightBarItem)
            
            case .select:
                selectAlbumPhoto(sender: sender)
        }
    }
}

// MARK: - Extension UICollectionView DataSource
extension DetailAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchPHAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierCell.detailAlbumCell.rawValue, for: indexPath) as? DetailAlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let image = PhotoManager.photoInstance.fetchImagefromPhotoAsset(asset: self.fetchPHAsset[indexPath.row]) {
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
        } else {
            // MARK: 선택 모드가 아닌 경우 상세한 사진으로 이동한다.
            showStoryboard(indexPath: indexPath, group: DispatchGroup())
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
