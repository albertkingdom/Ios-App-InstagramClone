//
//  NewArticleViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/10/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class NewArticleViewController: UIViewController {
    var db: Firestore!
    var isSelectImage = false
    var isUploading: Bool = false {
        didSet {
            if (isUploading) {
//                uploadingMask.isHidden = false
//                uploadingMaskView.isHidden = false
//                uploadingMaskInfo.text = "發佈中..."
                let loadingVC = LoadingViewController()
                present(loadingVC, animated: true, completion: nil)
            } else {
//                uploadingMask.isHidden = true
//                uploadingMaskView.isHidden = true
                
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    var isCompleteUploading: Bool = false {
        didSet {
            if (isCompleteUploading) {
                uploadingMaskInfo.text = "發佈成功!"
            } else {
                uploadingMask.isHidden = true
                uploadingMaskView.isHidden = true
            }
        }
    }
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var postContent: UITextView!
    
    @IBAction func clickFinishButton(_ sender: Any) {
        if !isSelectImage {
            let alertC = UIAlertController(title: nil, message: "請選取照片！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alertC.addAction(okAction)
            present(alertC, animated: true, completion: nil)
            return
        }
        guard let imageData = self.postImage.image?.jpegData(compressionQuality: 0.8) else {
            fatalError("no image")
        }
        isUploading = true
        uploadImage(data: imageData ){ [weak self] (link:String?, error:Error?) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            if let link = link {
                // success
                print("imgur upload link \(link)")
                self?.uploadToFirebase(link: link)
            }
            
        }
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    
    @IBOutlet weak var uploadingMask: UIView!
    @IBOutlet weak var uploadingMaskInfo: UILabel!
    @IBOutlet weak var uploadingMaskView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.pickImage))
        postImage.addGestureRecognizer(tapGR)
        postImage.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem?.title = "分享"
        // textView
        postContent.layer.borderWidth = 1
        postContent.layer.borderColor = UIColor.gray.cgColor
        postContent.layer.cornerRadius = 10
        
        //mask
        uploadingMask.isHidden = true
        uploadingMaskView.isHidden = true
        uploadingMaskView.layer.cornerRadius = 10
        
    }
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("UIImageView tapped")
        }
    }
    @objc func pickImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let pickImageAlertController = UIAlertController(title: "插入照片", message: "選擇照片來源", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let albumAction = UIAlertAction(title: "Album", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickImageAlertController.addAction(cameraAction)
        }
        pickImageAlertController.addAction(albumAction)
        present(pickImageAlertController, animated: true, completion: nil)
    }
    
    
    func uploadToFirebase(link: String) {
        let loginUserEmail =  Auth.auth().currentUser?.email
        let postRef = db.collection("post").document()
        let post = Post(imageLink: link, postContent: self.postContent.text, userEmail: loginUserEmail, commentList: nil, timestamp: nil)
        
        do {
            try postRef
                .setData(from: post)
//            isCompleteUploading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // switch tab
                self.tabBarController?.selectedIndex = 0
            }
           
        }catch let error {
            
            fatalError("Error adding document \(error)" )
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("new article vc viewWillDisappear")
        postContent.text = nil
        isSelectImage = false
        postImage.image = UIImage(systemName: "photo")
        isUploading = false
    }
    
}
extension NewArticleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // implement methods in UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            postImage.image = image
            isSelectImage = true
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
