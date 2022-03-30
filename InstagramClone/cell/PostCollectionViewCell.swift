//
//  PostCollectionViewCell.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/9/21.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userName_one: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userName_two: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var heartAnimateImage: UIImageView!

    @IBAction func clickLikeButton(_ sender: Any) {
        //print("clickLikeButton...before..\(isLike)")
        self.isLike = !self.isLike
        //print("clickLikeButton...after..\(isLike)")
        if isLike {
  
            self.delegate?.addToLike(from: self)
            likeCount+=1
        } else {

            self.delegate?.removeLike(from: self)
            likeCount-=1

        }
    }
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeHeartWidth: NSLayoutConstraint!
    @IBOutlet weak var likeCountLabel: UILabel!
    var index: Int!
    lazy var likeAnimator = LikeAnimator(image: heartAnimateImage)
    var likeCount: Int = 0 {
        didSet {
            likeCountLabel.text = " \(likeCount)個讚"
        }
    }
    var isLike: Bool = false {
        didSet {
            //print("index = \(index)...set isLike...\(isLike)")
            
            if isLike {
                likeButton.tintColor = .red
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                likeButton.tintColor = .systemGray
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
       
            }
        }
    }
    var loginUserEmail: String!
    weak var delegate: ProductListCellDelegate?

    @objc func didDoubleTap() {
        print("didDoubleTap")
        
        if !isLike {
            likeAnimator.animateAlpha {
                self.delegate?.addToLike(from: self)
            }
            
            isLike = true
            likeCount+=1
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //backgroundColor = .green
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(clickUserName))
        let doubleTapGR: UITapGestureRecognizer = {
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
            tapGR.numberOfTapsRequired = 2
            //tapGR.cancelsTouchesInView = false
            return tapGR
        }()
        userName_one.addGestureRecognizer(tapGR)
        userName_one.isUserInteractionEnabled = true
        
        likeButton.tintColor = .systemGray
        commentButton.tintColor = .systemGray
       
        postImage.addGestureRecognizer(doubleTapGR)
    }
    
    @IBAction func clickCommentButton(_ sender: Any) {
        self.delegate?.onTouchCommentButton(from: self)
    }
    func configure(with data: Post, loginUserEmail: String){
        userName_one.text = data.userEmail
        userName_two.text = data.userEmail
        postContent.text = data.postContent ?? ""
        if let imageLink = data.imageLink {
            downloadImage(url: imageLink)
        }
        self.loginUserEmail = loginUserEmail
        // configure heart button
        if let likeByUserList = data.likeByUsers, likeByUserList.contains(where: { user in
            user.userEmail == loginUserEmail
        }) {

            isLike = true

        } else {

            isLike = false

        }
        if let likeByUserList = data.likeByUsers {
            likeCount = likeByUserList.count
        }
    }
    func downloadImage(url: String) {
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.postImage.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
    @objc func clickUserName() {
        self.delegate?.onTouchUserName(from: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImage.image = nil
        self.isLike = false
    }
    
    
}
