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
    @IBAction func clickLikeButton(_ sender: Any) {
        isLike = !isLike
        if isLike {
            likeButton.tintColor = .red
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeButton.tintColor = .black
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    
    }
    @IBOutlet weak var commentButton: UIButton!
    var index: Int!
    var isLike = false
    weak var delegate: ProductListCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //backgroundColor = .green
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(clickUserName))
        userName_one.addGestureRecognizer(tapGR)
        userName_one.isUserInteractionEnabled = true
       
    }
    
    @IBAction func clickCommentButton(_ sender: Any) {
        self.delegate?.onTouchButton(from: self)
    }
    func configure(with data: Post){
        userName_one.text = data.userEmail
        userName_two.text = data.userEmail
        postContent.text = data.postContent ?? ""
        if let imageLink = data.imageLink {
            downloadImage(url: imageLink)
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
   
}
