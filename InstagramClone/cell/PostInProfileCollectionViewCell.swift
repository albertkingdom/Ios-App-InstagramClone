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
            downloadImage(url: imageLink)
        }
    }
    func downloadImage(url: String) {
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.imageView.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
}
