//
//  StoryCollectionViewCell.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/7.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var postData: Post!
    override func awakeFromNib() {
        super.awakeFromNib()

        containView.layer.cornerRadius = frame.height
        containView.layer.borderColor = UIColor.systemPink.cgColor
        containView.layer.borderWidth = 2
        containView.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = frame.height * 0.9

        imageView.layer.masksToBounds = true

        

    }
    
    func configure(with data: Post){
        
       
        if let imageLink = data.imageLink {

            
            DownLoadImageService.shared.downloadImage(url: imageLink) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        //print("imageLink \(imageLink)...postData.imageLink \(self.postData.imageLink)")
                        // because cell will be reused, and download image takes time, check image link is same, if same, change image, if not same, don't change image
                        if imageLink == self.postData.imageLink {
                            print("is same imageLink")
                            self.imageView.image = UIImage(data: data)
                        } else {
                            print("is not same imageLink")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    override func prepareForReuse() {
        self.imageView.image = nil //when reused, temporary reset image
    }
    func setup(with image: UIImage){
        self.imageView.image = image
    }

}
