//
//  UpdateProfileViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/13/21.
//

import UIKit
import FirebaseAuth

class UpdateProfileViewController: UIViewController {
    var isLogin = Auth.auth().currentUser
    var isSelectImage: Bool = false
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overCurrentContext
        newNameTextField.isHidden = true
        // Do any additional setup after loading the view.
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        
        if let profilePhotoUrl = Auth.auth().currentUser?.photoURL{
            downloadAvatorImage(url: profilePhotoUrl)
        } else {
            profileImage.image = UIImage(systemName: "person.circle")
        }
        
        // add gesture to profileImage
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.pickImage))
        profileImage.addGestureRecognizer(tapGR)
        profileImage.isUserInteractionEnabled = true
        
        finishButton.layer.borderWidth = 1
        finishButton.layer.borderColor = UIColor.black.cgColor
        finishButton.layer.cornerRadius = 3
        finishButton.backgroundColor = UIColor.systemBackground
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
    
    @IBAction func updateProfile() {
        if (isLogin == nil) {
            print("update profile fragment user is null")
            return
        }
        if isSelectImage, let imageData = self.profileImage.image?.jpegData(compressionQuality: 0.8) {
            uploadImage(data: imageData ){ [weak self] (link:String?, error:Error?) in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
                if let link = link {
                    // success upload post image
                    print("imgur upload link \(link)")
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    //changeRequest?.displayName = displayName
                    changeRequest?.photoURL = URL(string: link)
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("\(error)")
                        }
                        
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
        } else {
            // without new image
            let alertVC = UIAlertController(title: "更換頭貼", message: "請選擇新照片", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
        
        
        
    }
    
    func downloadAvatorImage(url: URL) {
        
        downloadImage(url: url.absoluteString) { imageData in
            DispatchQueue.main.async {
                if self.isLogin != nil{
                    self.profileImage.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    
}

extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // implement methods in UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            isSelectImage = true
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
