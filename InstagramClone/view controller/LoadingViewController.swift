//
//  LoadingViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/15/21.
//

import UIKit

class LoadingViewController: UIViewController {
    var loadingText: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()
    var textLabel: UILabel = {
       let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "Uploading..."
        return textLabel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .white
        view.alpha = 0.8
        
        
        loadingText.addSubview(textLabel)
        
        view.addSubview(loadingText)
        NSLayoutConstraint.activate([
            loadingText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingText.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingText.heightAnchor.constraint(equalToConstant: 150),
            loadingText.widthAnchor.constraint(equalToConstant: 150),
            textLabel.centerXAnchor.constraint(equalTo: loadingText.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: loadingText.centerYAnchor),
            
        ])
        
        
    }
    

   

}
