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

class ProfileViewController: UIViewController {
    var db: Firestore!
    var singleUserPostIdList: [String] = []
    var singleUserPostList: [Post] = []
    var followingUserList: [String] = []
    var othersfollowingUserList: [String] = []
    var email: String?
    @IBOutlet weak var horizontalScrollBar: UIView!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    
    @IBOutlet weak var fansCount: UILabel!
    @IBAction func clickButtonOne(_ sender: Any) {
        scrollView.scrollRectToVisible(collectionView.frame, animated: true)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
           
            self.horizontalScrollBar.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    @IBAction func clickButtonTwo(_ sender: Any) {
        scrollView.scrollRectToVisible(collectionViewTwo.frame, animated: true)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
           
            self.horizontalScrollBar.transform = CGAffineTransform(translationX: self.horizontalScrollBar.frame.width, y: 0)
        }, completion: nil)
    }
    @IBAction func clickProfileMenu(_ sender: Any) {
        let profilMenuController = UIAlertController(title: "Menu", message: "", preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "登出", style: .default) { _ in
            self.signOut()
        }
        let updateProfileAction = UIAlertAction(title: "update profile", style: .default) { _ in
            
        }
        let dimissAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            profilMenuController.dismiss(animated: true, completion: nil)
        }
        profilMenuController.addAction(signOutAction)
        profilMenuController.addAction(updateProfileAction)
        profilMenuController.addAction(dimissAction)
        present(profilMenuController, animated: true, completion: nil)
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewTwo: UICollectionView!
    @IBOutlet weak var updateProfileButton: UIButton!
    
    @IBAction func touchUpdateProfileButton(_ sender: Any) {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "updateProfilePage") as! UpdateProfileViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        updateProfileButton.layer.borderWidth = 1
        updateProfileButton.layer.cornerRadius = 3
        updateProfileButton.layer.borderColor = UIColor.systemGray.cgColor
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action:  #selector(clickProfileMenu(_:)))
//        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "line.3.horizontal")
        //UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(clickProfileMenu(_:)))
//        profileName.text = Auth.auth().currentUser?.email
        if let profilePhotoUrl = Auth.auth().currentUser?.photoURL {
            print("profilePhotoUrl..\(profilePhotoUrl)")
            downloadImage(url: profilePhotoUrl)
        }
//        let loginUserEmail =  Auth.auth().currentUser?.email
        if let email = email {
            getSingleUserPost(email: email)
            getFollowingUser(email: email)
            getFans(email: email)
            profileName.text = email

        } else {
            let loginUserEmail =  Auth.auth().currentUser?.email
            getSingleUserPost(email: loginUserEmail)
            getFollowingUser(email: loginUserEmail)
            getFans(email: loginUserEmail)
            profileName.text = loginUserEmail
            
        }
    }
    private func generateLayout() -> UICollectionViewLayout {
        //let spacing: CGFloat = 20
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        //        section.contentInsets = NSDirectionalEdgeInsets(top: 400, leading: 0, bottom: 0, trailing: 0)
        //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    func signOut() {
        try? Auth.auth().signOut()
        //performSegue(withIdentifier: "toLogin", sender: nil)
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
        
        let postRef = db.collection("post")
        
        guard let email = email else {
            fatalError()
        }
        let query = postRef.whereField("userEmail", isEqualTo: email).order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            document.documents.forEach { item in
                print("value.document...\(item.documentID)")
            }
            let tempIdList = document.documents.map {
                $0.documentID
            }
            self.singleUserPostIdList = tempIdList
            
            let tempPostList = document.documents.map { QueryDocumentSnapshot -> Post in
                
                
                guard let post = try? QueryDocumentSnapshot.data(as: Post.self) else { fatalError() }
                print(post)
                
                
                
                
                return post
                
            }
            //                print("Current data: \(tempPostList)")
            self.singleUserPostList = tempPostList
            self.postCount.text = "\(String(self.singleUserPostList.count))\n 文章"
            self.collectionView.reloadData()
            
        }
        
    }
    
    func downloadImage(url: URL) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async { /// execute on main thread
                if let email = self.email {
                    
                } else {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }
        
        task.resume()
        
    }
    func getFollowingUser(email: String?) {
        let loginUserEmail = Auth.auth().currentUser?.email
        guard let email = email else { return }
        let userListRef = db.collection("userList").document(email)
        
        
        userListRef.getDocument{ documentSnapshot, error in
            
            
            let followList = documentSnapshot.map{ documentSnapshot -> [String] in
                
                guard let follow = try? documentSnapshot.data(as: Follow.self)?.followingUserEmail else { fatalError() }
                //print(follow)
                return follow
                
            }
            
            print("followlist..\(followList)")
            
            
            
            
            if let followList = followList {
                if email == loginUserEmail {
                    self.followingUserList = followList
                    self.followingCount.text = "\( self.followingUserList.count)\n 追蹤"
                } else {
                    self.othersfollowingUserList = followList
                    self.followingCount.text = "\( self.othersfollowingUserList.count)\n 追蹤"
                }
            }
        }
        
    }
    
    
    func getFans(email: String?) {
        
        let loginUserEmail = Auth.auth().currentUser?.email
       
        guard let email = email else { return }

        let query = db.collection("userList").whereField("followingUserEmail", arrayContains: email)
            query.addSnapshotListener { value, e in
            if (e != nil) {
                print("Listen failed.\(e)")
               return
            }
            if value != nil, let fansCount = value?.documents.count {
                print("get fans...\(fansCount)")
                self.fansCount.text = "\(fansCount) \n 粉絲"
            }

        }


    }
    
}
