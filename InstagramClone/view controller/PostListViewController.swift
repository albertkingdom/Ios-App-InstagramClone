//
//  PostListViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/9/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class PostListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    lazy var firebaseService = {
        return FirebaseService()
    }()
    var db: Firestore!
    var listener: ListenerRegistration!
    
    var postList : [Post] = [] {
        didSet {
            if oldValue.count == 0 {
                // only reload all data when first time retrieving data, preventing collectionView flashing when any modified
                collectionView.reloadData()
            }
        }
    }
                                 
    var postIdList: [String] = []
    let userDefault = UserDefaults.standard
    let currentLoginUserEmail = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PostListViewController viewdidload")
        db = Firestore.firestore()
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "storyCell")
        collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "postCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        self.tabBarController?.tabBar.barTintColor = .white
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PostListViewController viewWillAppear")
        getPost()
    }

    private func generateLayout() -> UICollectionViewLayout {
        // layout for section 0 (story)
        let sectionZero: NSCollectionLayoutSection = {
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            //item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 0, trailing: 3)
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 5
          
            return section
        }()
        // layout for section 1 (post)
        let sectionOne: NSCollectionLayoutSection = {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            
           
            return section
        }()
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            // change layout based on section index
            switch sectionIndex {
            case 0:
                return sectionZero
                
            default:
                return sectionOne
            }

        }
        return layout
    }
  


    func getPost(){
       
        // Create a query against the collection.
        let postRef = db.collection("post")
        
        let query = postRef.whereField("userEmail", isNotEqualTo: currentLoginUserEmail).order(by: "userEmail").order(by: "timestamp", descending: true)
        listener = query
            .addSnapshotListener { documentSnapshot, error in
                
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
               
                
                let posts = document.documents.map { QueryDocumentSnapshot -> Post  in
                    
                    guard let post = try? QueryDocumentSnapshot.data(as: Post.self) else {
                        fatalError("\(error?.localizedDescription)" as! String)
                    }

                    return post
                }
                
                let postsIds = document.documents.map { QueryDocumentSnapshot -> String in
                    guard let id = try? QueryDocumentSnapshot.documentID else {
                       fatalError()
                    }
              
                    return id
                }
                // save document id to user default
                if let emailAddress = self.currentLoginUserEmail {
                    self.userDefault.setValue([emailAddress:postsIds], forKey: "postIds")
                }

                self.postList = posts
                self.postIdList = postsIds
                //print("will reload collection view!")
                //self.collectionView.reloadData()
                
                document.documentChanges.forEach { diff in
                    // listen for data added and send notification to user
                    if diff.type == .added, let userEmail = diff.document.data()["userEmail"] as? String, let savedDocumentIds = self.userDefault.object(forKey: "postIds") as? [String: [String]]{

                        if let index = savedDocumentIds[self.currentLoginUserEmail!]?.firstIndex(where: { id in
                            id == diff.document.documentID
                            
                        }) {
                            // existing post
                        }else {
                            // new post, send local notification
                            LocalNotification.sendLocalNotification(email: userEmail)
                        }
                        
                        
                    }
                    // listen for data modified
                    if diff.type == .modified {
                        
                        let modifiedIndex = self.postIdList.firstIndex(of: diff.document.documentID)

                        print("will reload items-----\(modifiedIndex)")
                        // only update the modified item
                        self.collectionView.reloadItems(at: [IndexPath(item: modifiedIndex!, section: 1)])
                    }
                }
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
    }
}

extension PostListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let post = postList[indexPath.row] as? Post else { return }
        
        switch indexPath.section {
        case 0:
            let detailVC = storyboard?.instantiateViewController(withIdentifier: "storyDetailVC") as! StoryDetailViewController
            detailVC.modalTransitionStyle = .crossDissolve
            detailVC.modalPresentationStyle = .fullScreen
            
          
            detailVC.postData = self.postList
            //detailVC.imagesList = self.imagesList
            detailVC.currentImageIndex = indexPath.row

            present(detailVC, animated: true, completion: nil)
        case 1:
            break
        default:
            break
        }
  
    }
    
}

extension PostListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return postList.count
        case 1:
            return postList.count
        default:
            break
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoryCollectionViewCell
            let post = postList[indexPath.row]
            cell.configure(with: post)
            //cell.setup(with: imagesList[indexPath.row])
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        let post = postList[indexPath.row]
        cell.configure(with: post, loginUserEmail: currentLoginUserEmail!)
        cell.delegate = self
        cell.index = indexPath.row
        

        return cell
        
    }
    

}

protocol ProductListCellDelegate: AnyObject {
    func onTouchCommentButton(from cell: PostCollectionViewCell)
    func onTouchUserName(from cell: PostCollectionViewCell)
    func addToLike(from cell: PostCollectionViewCell)
    func removeLike(from cell: PostCollectionViewCell)
}
extension PostListViewController: ProductListCellDelegate {
    
    
    func onTouchCommentButton(from cell: PostCollectionViewCell) {
        let post = postList[cell.index]
        let commentList = post.commentList
        let postId = postIdList[cell.index]
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "commentList") as! CommentListViewController
        nextVC.commentList = commentList
        nextVC.postId = postId
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func onTouchUserName(from cell: PostCollectionViewCell) {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "profilePageClone") as! ProfileViewController
        nextVC.email = cell.userName_one.text
        navigationController?.pushViewController(nextVC, animated: true)
    }
    // click like button
    func addToLike(from cell: PostCollectionViewCell) {
        
        let postId = postIdList[cell.index]
        
        firebaseService.addToLike(postId: postId)
    }
    
    func removeLike(from cell: PostCollectionViewCell) {
        
       
        let postId = postIdList[cell.index]
       
        firebaseService.removeLike(postId: postId)
      
    }
     
}

extension PostListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.collectionView) == true {
            return true
        }
        return false
    }
}
