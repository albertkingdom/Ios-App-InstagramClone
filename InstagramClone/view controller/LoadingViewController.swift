//
//  LoadingViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/15/21.
//

import UIKit

class LoadingViewController: UIViewController {
    var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()
    var textLabel: UILabel = {
       let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "Uploading..."
        textLabel.textColor = .white
        return textLabel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
        
        
        loadingView.addSubview(textLabel)
        
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 150),
            loadingView.widthAnchor.constraint(equalToConstant: 150),
            textLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            
        ])
        
        
    }
    

   

}
