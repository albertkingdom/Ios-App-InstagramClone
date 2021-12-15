//
//  TestViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/12/21.
//

import UIKit

class TestViewController: UIViewController {

    @IBAction func moveButton(_ sender: Any) {
//        leadingConstraint.constant = 50
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
           
            self.rectBiew.transform = CGAffineTransform(translationX: self.rectBiew.frame.width, y: 0)
        }, completion: nil)
    }
    @IBOutlet weak var rectBiew: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    

}
