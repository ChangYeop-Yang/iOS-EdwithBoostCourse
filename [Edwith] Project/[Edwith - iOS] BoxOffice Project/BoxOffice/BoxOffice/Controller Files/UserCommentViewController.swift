//
//  UserCommentViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 23/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class UserCommentViewController: UIViewController {
    
    // MARK: - Enum
    private enum NavigationItemTag: Int {
        case left   = 1000
        case right  = 2000
    }
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var movieNameLabel:              UILabel!
    @IBOutlet private weak var movieAgeImageView:           UIImageView!
    @IBOutlet private weak var movieUserRatingLabel:        UILabel!
    @IBOutlet private weak var movieUserRatingBar:          StarRatingControl!
    @IBOutlet private weak var movieUserCommentTextView:    UITextView!
    @IBOutlet private weak var movieUserName:               UITextField!
    
    // MARK: - Object Variables
    private var movieRating: CGFloat = 0.0
    private let placeholder: String = "한줄평을 작성해주세요."
    internal var informationMovie: (name: String, id: String, age: Int)?
    private let NICKNAME_USER_DEFAULT_KEY: String = "KEY_USER_NAME"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.movieUserRatingBar.delegate = self
        
        // MARK: Create NavigationBar left, right button.
        createNavigationItem()
        
        // MARK: Setting TextView Layer and Delegate.
        setUserCommentTextView(radius: 10.0, width: 1.0)
        
        // MARK: Register NotificationCenter
        NotificationCenter.default.addObserver(self
            , selector: #selector(didReceiveUploadResult)
            , name: NotificationName.movieUserUploadComment.name
            , object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Show Movie Information and User NickName.
        showMovieInformationAndUserName()
    }
    
    // MARK: - Event Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Extension UserCommentViewController
private extension UserCommentViewController {
    
    // MARK: - User Method
    func showMovieInformationAndUserName() {
    
    DispatchQueue.main.async { [weak self] in
        guard let self = self, let information = self.informationMovie else { return }
        
        // MARK: Setting Movie Name and Age.
        self.movieNameLabel.text = information.name
        seperateAgeType(age: information.age, imageView: self.movieAgeImageView)
        
        // MARK: Load User Nickname from UserDefault.
        if let name: String = UserDefaults.standard.string(forKey: self.NICKNAME_USER_DEFAULT_KEY) {
            // 기존에 작성했던 닉네임이 있다면 화면3으로 새로 진입할 때 기존의 닉네임이 입력되어 있습니다.
            self.movieUserName.text = name
        }
    }
}
    func setUserCommentTextView(radius: CGFloat, width: CGFloat) {
        
        self.movieUserCommentTextView.delegate              = self
        self.movieUserCommentTextView.layer.borderWidth     = width
        self.movieUserCommentTextView.layer.cornerRadius    = radius
        self.movieUserCommentTextView.layer.borderColor     = UIColor.red.cgColor
        
        self.movieUserCommentTextView.text      = "한줄평을 작성해주세요."
        self.movieUserCommentTextView.textColor = UIColor.lightGray
    }
    func createNavigationItem() {
        
        self.title = "한줄평 작성"
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // MARK: Left UIBarButton Item
        let left = UIBarButtonItem.init(title: "취소"
            , style: .done
            , target: self
            , action: #selector(actionNavigationItems(_:)) )
        left.tag = NavigationItemTag.left.rawValue
        
        // MARK: Right UIBarButton Item
        let right = UIBarButtonItem.init(title: "완료"
            , style: .plain
            , target: self
            , action: #selector(actionNavigationItems(_:)) )
        right.tag = NavigationItemTag.right.rawValue
        
        self.navigationItem.leftBarButtonItem   = left
        self.navigationItem.rightBarButtonItem  = right
    }
    func uploadUserComment() {
        
        // MARK: Check User Comment TextView and User Nickname TextFiled.
        guard checkWriteCondition() else { return }
        
        guard let writer:   String  = self.movieUserName.text
            , let rating:   String  = self.movieUserRatingLabel.text
            , let id:       String  = self.informationMovie?.id
            , let content:  String  = self.movieUserCommentTextView.text
            , let score:    Double  = Double(rating)
            else { return }
        
        // 기존에 작성했던 닉네임이 있다면 화면3으로 새로 진입할 때 기존의 닉네임이 입력되어 있습니다.
        UserDefaults.standard.set(writer, forKey: self.NICKNAME_USER_DEFAULT_KEY)
        
        // 영화정보를 가져오거나 한줄평을 등록하는 과정은 첨부한 API 문서를 참고하여 URLSession을 활용하여 서버와 통신합니다.
        let comment: UserComment = UserComment(rating: score, writer: writer, movieID: id, contents: content)
        ParserMovieJSON.shared.uploadMovieUserComment(type: ParserMovieJSON.MovieParserType.comment.rawValue
            , subURI: ParserMovieJSON.SubURI.upload.rawValue
            , parameter: comment, self)
    }
    func checkWriteCondition() -> Bool {
        
        // 사용자가 User Name을 작성하지 않은 경우
        if self.movieUserName.text == "" || self.movieUserCommentTextView.text == self.placeholder {
            // 닉네임 또는 한줄평이 모두 작성되지 않은 상태에서 '완료' 버튼을 누르면 경고 알림창이 뜹니다.
            let comment = "닉네임 또는 사용자 코멘트를 입력하여주세요."
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let alert: UIAlertController = UIAlertController(title: "‼️ ERROR, Empty Contents (3477)", message: comment, preferredStyle: .alert)
                alert.addAction( UIAlertAction(title: "✅ 확인", style: .default, handler: nil) )
                
                self.present(alert, animated: true, completion: nil)
            }
            
            return false
        }
        
        return true
    }
    
    // MARK: - Objective-C Method
    @objc func didReceiveUploadResult(_ noti: Notification) {
        
        guard let receive = noti.userInfo, let status = receive[GET_KEY] as? Bool else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 데이터 수신 또는 한줄평 등록에 실패한 경우, 알림창을 통해 사용자에게 결과를 표시해야 합니다.
            if status == false || self.movieRating == 0.0 {
                let alert = UIAlertController(title: "‼️ Error, Upload Fail (3478)"
                    , message: "현재 서버에 응답이 없거나 영화 별점 점수를 매겨주세요."
                    , preferredStyle: .alert)
                alert.addAction( UIAlertAction(title: "✅ 확인", style: .default, handler: nil) )
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func actionNavigationItems(_ item: UIBarButtonItem) {
        
        guard let tag = NavigationItemTag(rawValue: item.tag) else { return }
        
        switch tag {
        case .left:
            // '취소'버튼을 누르면 이전 화면으로 되돌아갑니다.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
        case .right:
            // 작성자의 닉네임과 한줄평을 작성하고 '완료' 버튼을 누르면 새로운 한줄평을 등록하고 등록에 성공하면 이전화면으로 되돌아오고, 새로운 한줄평이 업데이트됩니다.
            uploadUserComment()
        }
    }
}

// MARK: - Extension UpdateStarRatingScore Delegate
extension UserCommentViewController: UpdateStarRatingScore {
    
    func updateStarRating(score: CGFloat) {
        // 선택된 별이 숫자로 환산돼 별 이미지 아래쪽에 보입니다.
        self.movieRating = score.rounded()
        self.movieUserRatingLabel.text = String(format: "%d", Int(self.movieRating) )
    }
}

// MARK: - Extension UITextViewDelegate
extension UserCommentViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text               = self.placeholder
            textView.textColor          = UIColor.lightGray
            textView.layer.borderColor  = UIColor.red.cgColor
        } else {
            textView.textColor          = UIColor.black
            textView.layer.borderColor  = UIColor.lightGray.cgColor
        }
    }
    
    // https://developer.apple.com/documentation/uikit/uitextviewdelegate/1618630-textview
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == self.placeholder {
            textView.text = String()
        }
        return true
    }
}
