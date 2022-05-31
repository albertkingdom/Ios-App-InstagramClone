//
//  PostInProfileCollectionViewCell.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/10/21.
//

import UIKit

class PostInProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    func configure(with data: Post){
        
        if let imageLink = data.imageLink {
            
            DownLoadImageService.shared.downloadImage(url: imageLink) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
