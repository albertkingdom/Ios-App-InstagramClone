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
    var db: Firestore!
    var listener: ListenerRegistration!
    
    var postList : [Post] = []
                                 
    var postIdList: [String] = []
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("PostListViewController viewdidload")
        db = Firestore.firestore()
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "storyCell")
        collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "postCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        self.tabBarController?.tabBar.barTintColor = .white
        getPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("PostListViewController viewWillAppear")

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
        let loginUserEmail =  Auth.auth().currentUser?.email
        let query = postRef.whereField("userEmail", isNotEqualTo: loginUserEmail).order(by: "userEmail").order(by: "timestamp", descending: true)
        listener = query
            .addSnapshotListener { documentSnapshot, error in
               
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
                document.documentChanges.forEach { diff in
                    if diff.type == .added, let userEmail = diff.document.data()["userEmail"] as? String, let savedDocumentIds = self.userDefault.object(forKey: "postIds") as? [String: [String]]{
                        //print("document diff post email \(userEmail)... id...\(diff.document.documentID)")
                        //print("savedDocumentIds...\(savedDocumentIds[loginUserEmail!])")
                        if let index = savedDocumentIds[loginUserEmail!]?.firstIndex(where: { id in
                            id as! String == diff.document.documentID
                            
                        }) {
                            // existing post
                        }else {
                            // new post, send local notification
                            LocalNotification.sendLocalNotification(email: userEmail)
                        }
                        
                        
                    }
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
                self.userDefault.setValue([loginUserEmail:postsIds], forKey: "postIds")

                self.postList = posts
                self.postIdList = postsIds
                self.collectionView.reloadData()
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
            let post = postList[indexPath.row]
            let commentList = post.commentList
            let postId = postIdList[indexPath.row]
            
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "commentList") as! CommentListViewController
            nextVC.commentList = commentList
            nextVC.postId = postId
            navigationController?.pushViewController(nextVC, animated: true)
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
        cell.configure(with: post)
        cell.delegate = self
        cell.index = indexPath.row
      
//        cell.commentButton.addTarget(self, action: #selector(navigateToCommentList), for: .touchUpInside)
        return cell
        
    }
    

}

protocol ProductListCellDelegate: AnyObject {
    func onTouchButton(from cell: PostCollectionViewCell)
    func onTouchUserName(from cell: PostCollectionViewCell)
}
extension PostListViewController: ProductListCellDelegate {
    
    
    func onTouchButton(from cell: PostCollectionViewCell) {
        let post = postList[cell.index]
        let commentList = post.commentList
        let postId = postIdList[cell.index]
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "commentList") as! CommentListViewController
        nextVC.commentList = commentList
        nextVC.postId = postId
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func onTouchUserName(from cell: PostCollectionViewCell) {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "profilePage") as! ProfileViewControllerOld
        nextVC.email = cell.userName_one.text
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
     
}
