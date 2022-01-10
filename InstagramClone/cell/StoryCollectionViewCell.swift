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
    override func awakeFromNib() {
        super.awakeFromNib()
//        backgroundColor = .brown
//        layer.cornerRadius = frame.height
        containView.layer.cornerRadius = frame.height
        containView.layer.borderColor = UIColor.systemPink.cgColor
        containView.layer.borderWidth = 2
        containView.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = frame.height * 0.9

        imageView.layer.masksToBounds = true

        

    }
    
    func configure(with data: Post){
       
        if let imageLink = data.imageLink {

            downloadImage(url: imageLink) { data in
                DispatchQueue.main.async { /// execute on main thread
                    self.imageView.image = UIImage(data: data)


                }
            }
        }
        
    }
    
    func setup(with image: UIImage){
        self.imageView.image = image
    }

}
