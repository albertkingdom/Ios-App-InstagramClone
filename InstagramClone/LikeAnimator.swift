//
//  LikeAnimater.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/3/27.
//

import Foundation
import UIKit

class LikeAnimator {

    let image: UIImageView

    init(image: UIImageView){
        self.image = image
    }

    func animateAlpha(completion: @escaping () -> Void) {
        
       
        UIView.animate(withDuration: 0.8, animations: {
            self.image.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1) {
                self.image.alpha = 0
            }
            completion()
        }
    }
}
