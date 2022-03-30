//
//  CommentListViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/11/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class CommentListViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentTextView: UITextField!
    lazy var firebaseService = {
        return FirebaseService()
    }()
    var commentList: [Comment]? = []
    var postId: String!
    var db: Firestore!
    var keyboardheight: CGFloat!
    var isKeyboardShown = false
    
    @IBAction func sendButton(_ sender: Any) {
        if let comment = newCommentTextView.text {
        addComment(commentContent: comment)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.dataSource = self

        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        
        downloadAvatorImage()
        
        // keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.newCommentTextView.delegate = self
        
    }
   
    
    func addComment(commentContent: String) {
 
        firebaseService.addComment(commentContent: commentContent, postId: postId) {
            self.navigationController?.popViewController(animated: true)
        }
            
    }
    func downloadAvatorImage() {
        if let profilePhotoUrl = Auth.auth().currentUser?.photoURL {
            print("profilePhotoUrl..\(profilePhotoUrl)")
            
            downloadImage(url: profilePhotoUrl.absoluteString) { imageData in
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: imageData)
                }
            }
        }
    }

}

extension CommentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentListTableViewCell", for: indexPath)
        cell.selectionStyle = .none
        if let comment = commentList?[indexPath.row] {
        cell.textLabel?.text = comment.userEmail
            cell.textLabel?.font = .boldSystemFont(ofSize: 14)
        cell.detailTextLabel?.text = comment.commentContent
        }
        return cell

    }
}

extension CommentListViewController {
    @objc func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            
            keyboardheight = keyboardSize.height

          
            if !self.isKeyboardShown {
                self.view.frame = CGRect(x: .zero, y: .zero, width: self.view.frame.width, height: self.view.frame.height - keyboardSize.height)
                isKeyboardShown = true
            }

        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        if self.isKeyboardShown {
            self.view.frame = CGRect(x: .zero, y: .zero, width: self.view.frame.width, height: self.view.frame.height + keyboardheight)
            isKeyboardShown = false
        }
       
    }
}
extension CommentListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // to hide keyboard, send keyboardWillHideNotification
        textField.resignFirstResponder()
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil)
       
        return true
    }
}
