//
//  CommentListTestViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/15/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class CommentListTestViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentTextView: UITextField!
    var commentList: [Comment]? = []
    var postId: String!
    var db: Firestore!
    var activeField: UITextField?
    
    @IBAction func sendButton(_ sender: Any) {
        if let comment = newCommentTextView.text {
        addComment(commentContent: comment)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        //registerForKeyboardNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.newCommentTextView.delegate = self
        
        
        db = Firestore.firestore()
        //tableView.dataSource = self

        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        if let profilePhotoUrl = Auth.auth().currentUser?.photoURL {
            print("profilePhotoUrl..\(profilePhotoUrl)")
            downloadImage(url: profilePhotoUrl)
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //deregisterFromKeyboardNotifications()
    }
    
    func addComment(commentContent: String) {
 

        let postRef = db.collection("post").document(postId)
//        let newComment = Comment(userEmail: Auth.auth().currentUser?.email, commentContent: commentContent)
        let newComment: [String: Any] = ["userEmail": Auth.auth().currentUser?.email, "commentContent": commentContent]
      print("newComment..\(newComment)")
        postRef.updateData([
            "commentList": FieldValue.arrayUnion([newComment])
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.navigationController?.popViewController(animated: true)
            }
        }
            
    }
    func downloadImage(url: URL) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async { /// execute on main thread
                self.profileImageView.image = UIImage(data: data)
            }
        }
        
        task.resume()
        
    }

}

extension CommentListTestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentListTableViewCell", for: indexPath)
        cell.selectionStyle = .none
        if let comment = commentList?[indexPath.row] {
        cell.textLabel?.text = comment.userEmail
        cell.detailTextLabel?.text = comment.commentContent
        }
        return cell

    }
}

extension CommentListTestViewController {
//    func registerForKeyboardNotifications(){
//        //Adding notifies on keyboard appearing
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    func deregisterFromKeyboardNotifications(){
//        //Removing notifies on keyboard appearing
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }

//    @objc func keyboardWasShown(notification: NSNotification){
//        //Need to calculate keyboard exact size due to Apple suggestions
//        self.scrollView.isScrollEnabled = true
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
//
//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
//
//        var aRect : CGRect = self.view.frame
//        aRect.size.height -= keyboardSize!.height
//        if let activeField = self.activeField {
//            if (aRect.contains(activeField.frame.origin)){
//                print("true")
//                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
//                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
//            }
//        }
//    }
//
//    @objc func keyboardWillBeHidden(notification: NSNotification){
//        //Once keyboard disappears, restore original positions
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
//        self.view.endEditing(true)
//        self.scrollView.isScrollEnabled = false
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField){
//        activeField = textField
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField){
//        activeField = nil
//    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // to hide keyboard, send keyboardWillHideNotification
            textField.resignFirstResponder()
            
            return true
        }
}



