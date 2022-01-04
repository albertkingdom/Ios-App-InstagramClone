//
//  UITextFieldExtension.swift
//  InstagramClone
//
//  Created by Albert Lin on 2021/12/21.
//

import UIKit

extension UITextField {

    func setupRightButton(imageName:String){
      
        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: imageName), for: .normal)
        rightButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        rightView = rightButton
        rightViewMode = .always
        
        self.tintColor = .lightGray
        
        
    }
    @objc func pressedButton() {
        //print("press")
        self.isSecureTextEntry = !isSecureTextEntry
    }

}
