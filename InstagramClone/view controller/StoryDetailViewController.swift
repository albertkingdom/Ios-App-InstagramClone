//
//  StoryDetailViewController.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/7.
//

import UIKit

let TAG = "StoryDetailViewController"

class StoryDetailViewController: UIViewController {
    var postData: [Post] = []
    var currentImageIndex: Int! {
        
        didSet {
            downloadSelectedImages()
        }
    }
    
    var changeImageTimer: Timer?
   
    //var imagesList: [UIImage] = []
    var currentImage: UIImage! {
        didSet {
            if oldValue == nil {
                print("currentImage old value is nil")
                // load the image at first time complete download image
                self.imageView.image = currentImage
                
            }
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGesture()
        setupProgressView()

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
                dismiss(animated: true, completion: nil)
                changeImageTimer?.invalidate()
            case .left:
                //print("swipe left")
                changeImageTimer?.invalidate()
                
                //print("timer stop")
                if currentImageIndex + 1 <= postData.count - 1 {

                    currentImageIndex += 1
                }else {
                    dismiss(animated: true, completion: nil)
                    changeImageTimer?.invalidate()
                }
                
            default:
                break

            }
        }
    }
     
    
    
   
    

    func setupProgressView() {
        progressBar.progressTintColor = .blue

    }
    func setupProgressBarAnimation(){
        self.progressBar.setProgress(0, animated: false)
        self.progressBar.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              
           self.progressBar.setProgress(1.0, animated: false)
          
            UIView.animate(withDuration: 5, delay: 0, options: [], animations: { [unowned self] in
                self.progressBar.setProgress(1.0, animated: false)
                self.progressBar.layoutIfNeeded()
              
            })
 
        }
    }
    func autoChangeImage() {
        //print("autoChangeImage")
        
        // load the first image
        //self.imageView.image = self.currentImage
    
        setupProgressBarAnimation()
        
        // setup timer
        changeImageTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
            //print("timer start")
            //print("timer current index..\(self.currentImageIndex)")
            
            if self.currentImageIndex + 1 > self.postData.count - 1 {
                timer.invalidate() //stop timer
                
                self.dismiss(animated: true, completion: nil)
            }
            
            // MARK: image transition
            self.doTransition(index: self.currentImageIndex)
            
            //-----------
            self.setupProgressBarAnimation()

        }
  
      
    }
    
    // MARK: image transition
    func doTransition(index: Int) {
        let duration = 0.5

//        if index == imagesList.count - 1 {
//            return
//        }
        
        //print("do transition")
        UIView.transition(
            with: self.imageView,
            duration: duration,
            options: .transitionFlipFromRight
        ) {
            self.imageView.image = self.currentImage
        } completion: { finished in
            //print("success?..\(finished)")
            if self.currentImageIndex < self.postData.count - 1 {
                self.currentImageIndex += 1
            }
            
            // if there is completion callback passed in, do execute
//            if let afterTransitionTodo = completion {
//                afterTransitionTodo()
//            }
        }
        
        
    }
    
    func downloadSelectedImages()  {
        
        let post = postData[currentImageIndex]
        
        downloadImage(url: post.imageLink ?? "", completion: { data in
            DispatchQueue.main.async {
                
                self.currentImage = UIImage(data: data)!
                self.autoChangeImage()
            }
            
        })
        
    }
}
