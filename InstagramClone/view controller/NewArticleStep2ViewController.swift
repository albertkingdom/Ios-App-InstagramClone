//
//  NewArticleStep2ViewController.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/16.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class NewArticleStep2ViewController: UIViewController {
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    lazy var firebaseService = {
        return FirebaseService()
    }()
    var db: Firestore!
    var image: UIImage? = nil
    var isUploading: Bool = false {
        didSet {
            if (isUploading) {

                let loadingVC = LoadingViewController()
                loadingVC.modalTransitionStyle = .crossDissolve
                loadingVC.modalPresentationStyle = .overCurrentContext
                //loadingVC.isModalInPresentation = true
                present(loadingVC, animated: true, completion: nil)
            } else {

                let currentVC = presentedViewController as! LoadingViewController
                currentVC.textLabel.text = "Complete"
                cleanContext()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // dismiss LoadingVC
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                   
                    // switch tab
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
                }
            }
            
        }
        
    }
    @IBAction func clickFinishButton(_ sender: Any) {

        guard let imageData = self.postImage.image?.jpegData(compressionQuality: 0.8) else {
            fatalError("no image")
        }
        isUploading = true
        uploadImage(data: imageData ){ [weak self] (link:String?, error:Error?) in
            if let error = error {
                //fatalError(error.localizedDescription)
                print("upload failed...\(error.localizedDescription)")
                let alertC = UIAlertController(title: "Upload Failed", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertC.addAction(okAction)
                self?.present(alertC, animated: true, completion: nil)
            }
            if let link = link {
                // success
                print("imgur upload link \(link)")
                self?.uploadToFirebase(link: link)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        if let image = image {
            self.postImage.image = image
        }
        
        postContent.layer.borderWidth = 1
        postContent.layer.borderColor = UIColor.gray.cgColor
        postContent.layer.cornerRadius = 10
       
        finishButton.layer.cornerRadius = 5
        
        self.hideKeyboardWhenTappedAround()
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.popViewController(animated: true)
    }
    func uploadToFirebase(link: String) {
        let loginUserEmail =  Auth.auth().currentUser?.email
        let postRef = db.collection("post").document()
        let post = Post(imageLink: link, postContent: self.postContent.text, userEmail: loginUserEmail, commentList: nil, timestamp: nil)
        

        firebaseService.uploadNewPost(post: post) { error in
            if let error = error {
                //alert
            } else {
                self.isUploading = false
            }
        }
    }
    
    func cleanContext() {
        print("cleanContext")
        postContent.text = nil
//        isSelectImage = false
        postImage.image = UIImage(systemName: "photo")
    }

}
