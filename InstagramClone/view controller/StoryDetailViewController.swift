//
//  StoryDetailViewController.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/7.
//

import UIKit

let TAG = "StoryDetailViewController"

class StoryDetailViewController: UIViewController {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    var barAnimation: UIViewPropertyAnimator!
    var initialIndex = 0
    var postData: [Post] = []
    var currentImageIndex: Int! {
        
        didSet {
           
            print("index = \(String(describing: currentImageIndex))")
            if currentImageIndex < postData.count {
                downloadSelectedImages()
            }
            
            if currentImageIndex == postData.count {
                dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
   
    var currentImage: UIImage! {
        didSet {
            self.progressBar.setProgress(0.0, animated: false)
            
            cardFlip()
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGesture()
        
        barAnimation = configureProgressBarAnimation()

    }

    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear, progressbar progress = \(progressBar.progress)")
        self.currentImageIndex = initialIndex
    }
    func setupGesture() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeLeftGesture.direction = .left
        
        view.addGestureRecognizer(swipeLeftGesture)
    }
    @objc func swipe(gesture: UIGestureRecognizer){
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
                //print("swipe down")
                barAnimation.stopAnimation(true)
                dismiss(animated: true, completion: nil)

            case .left:
                //print("swipe left")

                currentImageIndex += 1
                barAnimation.stopAnimation(true)
                
                switch barAnimation.state {
                case .inactive:
                    print("animation state: inactive")
                case .active:
                    print("animation state: active")
                case .stopped:
                    print("animation state: stopped")
                default:
                    return
                }
              
            default:
                break

            }
        }
    }
     


   
    func configureProgressBarAnimation() -> UIViewPropertyAnimator {
        print("start animateBar")
        
        let animator = UIViewPropertyAnimator.init(duration: 3.0, curve: .linear) {
            
        }
        
        animator.addAnimations {
            self.progressBar.setProgress(1.0, animated: true)
        }
        
        animator.addCompletion {  _ in
            print("finish animate bar")
            
            self.progressBar.setProgress(0.0, animated: false)
            self.currentImageIndex += 1
        }
        
        return animator
    }
    

    func cardFlip() {
        let duration = 0.5
        
        //print("do transition")
        UIView.transition(
            with: self.imageView,
            duration: duration,
            options: .transitionFlipFromRight
        ) {
            self.imageView.image = self.currentImage
        } completion: { finished in
            print("card flip finished?..\(finished)")
            // run progress bar animation
            self.barAnimation = self.configureProgressBarAnimation() // reconfigure animation so that it can run again
            self.barAnimation.startAnimation()

        }
    }
    
    func downloadSelectedImages()  {
        self.progressBar.setProgress(0.0, animated: false)
        let post = postData[currentImageIndex]
        
        DownLoadImageService.shared.downloadImage(url: post.imageLink ?? "") { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    print("finish download image")
                    self.currentImage = UIImage(data: data)!
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
