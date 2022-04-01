//
//  ViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/8/21.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FacebookLogin

class ProfileViewController: UIViewController {
    
    var singleUserPostIdList: [String] = []
    var singleUserPostList: [Post] = []
    var followingUserList: [String] = []
    var othersfollowingUserList: [String] = []
    var email: String?
    var profileBottomVC: ProfileBottomViewController!
    lazy var firebaseService: FirebaseService = {
        return FirebaseService()
    }()
    @IBOutlet weak var containerViewLeftContstraint: NSLayoutConstraint!
    @IBOutlet weak var horizontalScrollBar: UIView!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!

    @IBOutlet weak var fansCount: UILabel!

    @IBAction func clickButtonOne(_ sender: Any) {

        containerViewLeftContstraint.constant = 0
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
           
            self.horizontalScrollBar.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.layoutIfNeeded() // animate the constraint change process
        }, completion: nil)
    }
    @IBAction func clickButtonTwo(_ sender: Any) {
        print("profileBottomVC.view.frame.width..\(profileBottomVC.view.frame.width)")
        containerViewLeftContstraint.constant = -profileBottomVC.view.frame.width
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
           
            self.horizontalScrollBar.transform = CGAffineTransform(translationX: self.horizontalScrollBar.frame.width, y: 0)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    @IBAction func clickProfileMenu(_ sender: Any) {
        let profilMenuController = UIAlertController(title: "Menu", message: "", preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "登出", style: .default) { _ in
            self.signOut()
        }
        
        let dimissAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            profilMenuController.dismiss(animated: true, completion: nil)
        }
        profilMenuController.addAction(signOutAction)
        profilMenuController.addAction(dimissAction)
        present(profilMenuController, animated: true, completion: nil)
    }

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!


    @IBOutlet weak var updateProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        

        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        updateProfileButton.layer.borderWidth = 1
        updateProfileButton.layer.cornerRadius = 3
        updateProfileButton.layer.borderColor = UIColor.systemGray.cgColor
        
       

        if let email = email {
            // for viewing other user profile
            getSingleUserPost(email: email)
            getFollowingUser(email: email)
            getFans(email: email)
            profileName.text = email
            navigationItem.rightBarButtonItem = nil
           
            checkLoginUserIsFollowingThisUser(email: email)
        } else {
            // viewing login user profile
            let loginUserEmail =  Auth.auth().currentUser?.email
            getSingleUserPost(email: loginUserEmail)
            getFollowingUser(email: loginUserEmail)
            getFans(email: loginUserEmail)
            profileName.text = loginUserEmail
            updateProfileButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
            updateProfileButton.setTitle("Update Profile", for: .normal)
        }
    }
    @objc func startFollowingUser(){
        firebaseService.startFollowingUser(email: email)
    }
    @objc func quitFollowingUser() {
        firebaseService.quitFollowingUser(email: email)
    }
    @objc func updateProfile(){
      
        let updateProfileVC = storyboard?.instantiateViewController(withIdentifier: "updateProfilePage") as! UpdateProfileViewController
        navigationController?.pushViewController(updateProfileVC, animated: true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let profilePhotoUrl = Auth.auth().currentUser?.photoURL {
            print("profilePhotoUrl..\(profilePhotoUrl)")
            downloadImage(url: profilePhotoUrl.absoluteString) { imageData in
                DispatchQueue.main.async {
                    if let email = self.email {
                        // for viewing other user profile
                    } else {
                        // viewing login user profile
                        self.profileImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    func signOut() {

        do {
            try Auth.auth().signOut()
            LoginManager().logOut() // log out fb
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        

        view.window?.rootViewController?.presentedViewController?.dismiss(animated: false)
        
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singleUserPostList.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postInProfileCollectionViewCell", for: indexPath) as! PostInProfileCollectionViewCell
        cell.configure(with: singleUserPostList[indexPath.row])
        return cell
    }
    
    
    func getSingleUserPost(email: String?) {
        
        firebaseService.getSingleUserPost(email: email) { tempIdList, tempPostList in
            self.singleUserPostList = tempPostList
            self.profileBottomVC.singleUserPostList = tempPostList
            self.postCount.text = "\(String(self.singleUserPostList.count))\n 文章"
            
            self.profileBottomVC.collectionView.reloadData()
        }
    }
    

    func getFollowingUser(email: String?) {
        let loginUserEmail = Auth.auth().currentUser?.email

        firebaseService.getFollowingUser(email: email) { followList in
            if email == loginUserEmail {
                self.followingUserList = followList
                self.followingCount.text = "\( self.followingUserList.count)\n 追蹤"
            } else {
                self.othersfollowingUserList = followList
                self.followingCount.text = "\( self.othersfollowingUserList.count)\n 追蹤"
            }
        }
        
    }
    
    
    func getFans(email: String?) {
        
        firebaseService.getFans(email: email) { fansCount in
            self.fansCount.text = "\(fansCount) \n 粉絲"
        }

    }
    func checkLoginUserIsFollowingThisUser(email: String?) {

        firebaseService.checkLoginUserIsFollowingThisUser(email: email) { loginUserIsFollowingThisUser in
            if loginUserIsFollowingThisUser {
                self.updateProfileButton.setTitle("追蹤中", for: .normal)
                self.updateProfileButton.addTarget(self, action: #selector(self.quitFollowingUser), for: .touchUpInside)
            } else {
                self.updateProfileButton.setTitle("追蹤", for: .normal)
                self.updateProfileButton.addTarget(self, action: #selector(self.startFollowingUser), for: .touchUpInside)
            }
        }
    }
    // MARK: prepare for container view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "profileBottomVC":
            let nextVC = segue.destination as! ProfileBottomViewController
            self.profileBottomVC = nextVC
        default:
            return
        }
    }
}
