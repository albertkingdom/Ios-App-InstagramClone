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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PostListViewController viewdidload")
        db = Firestore.firestore()
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "postCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PostListViewController viewWillAppear")
        getPost()
    }
    private func generateLayout() -> UICollectionViewLayout {
        //let spacing: CGFloat = 20
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
       
        //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
        
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
                
                let posts = document.documents.map { QueryDocumentSnapshot -> Post  in
                    print(QueryDocumentSnapshot.data())
                    guard let post = try? QueryDocumentSnapshot.data(as: Post.self) else {
                        fatalError("\(error?.localizedDescription)" as! String)
                    }

                    return post
//                    QueryDocumentSnapshot.data()
                }
                
                let postsIds = document.documents.map { QueryDocumentSnapshot -> String in
                    guard let id = try? QueryDocumentSnapshot.documentID else {
                       fatalError()
                    }
                   
                    return id
                }
                print("Current data: \(posts)")
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
        let post = postList[indexPath.row]
        let commentList = post.commentList
        let postId = postIdList[indexPath.row]
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "commentList") as! CommentListViewController
        nextVC.commentList = commentList
        nextVC.postId = postId
        navigationController?.pushViewController(nextVC, animated: true
        )
  
    }
    
}

extension PostListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "profilePage") as! ProfileViewController
        nextVC.email = cell.userName_one.text
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
     
}
