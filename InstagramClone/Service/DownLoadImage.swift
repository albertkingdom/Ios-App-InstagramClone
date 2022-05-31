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
class DownLoadImageService {
    
    static let shared = DownLoadImageService()
    
    func downloadImage(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else {
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
        
    }
    
}

