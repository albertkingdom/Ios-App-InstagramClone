//
//  DownLoadImage.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/7.
//

import Foundation

func downloadImage(url: String, completion: @escaping (Data) -> Void) {
    if let url = URL(string: url) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            
            completion(data)
        }
        
        task.resume()
    }
}
