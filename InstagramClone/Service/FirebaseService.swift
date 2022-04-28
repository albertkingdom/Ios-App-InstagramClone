//
//  FirebaseService.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/3/29.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseService {
    let currentLoginUserEmail = Auth.auth().currentUser?.email
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    // MARK: profileVC
    func getFollowingUser(email: String?, complete: @escaping ([String]) -> Void){
        guard let email = email else { return }
        let userListRef = db.collection("userList").document(email)
    
    
        userListRef.getDocument{ documentSnapshot, error in
            
            
            let followList = documentSnapshot.map{ documentSnapshot -> [String] in
                
                guard let follow = try? documentSnapshot.data(as: Follow.self)?.followingUserEmail else { return [] }
                //print(follow)
                return follow
                
            }
            if let followList = followList {
                complete(followList)
            }
        }
    
    }
    
    func getFans(email: String?, complete: @escaping (Int) -> Void) {
        guard let email = email else { return }
        
        let query = db.collection("userList").whereField("followingUserEmail", arrayContains: email)
        query.addSnapshotListener { value, e in
            if (e != nil) {
                print("Listen failed.\(e)")
                return
            }
            
            if value != nil,
               let fansCount = value?.documents.count
            {
                print("get fans...\(fansCount)")
                complete(fansCount)
                
            }
            
        }
    }
    
    func getSingleUserPost(email: String?, complete: @escaping (_ tempIdList:[String], _ tempPostList:[Post]) -> Void) {
        
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
            
            
            let tempPostList = document.documents.map { QueryDocumentSnapshot -> Post in
                
                
                guard let post = try? QueryDocumentSnapshot.data(as: Post.self) else { fatalError() }
                print(post)
                return post
                
            }
            
            complete(tempIdList, tempPostList)
            
            
        }
    }
    
    func checkLoginUserIsFollowingThisUser(email: String?, complete: @escaping (Bool)->Void) {
        
        guard let email = email else { return }
        guard let loginUserEmail = Auth.auth().currentUser?.email else { return }
        let ref = db.collection("userList").document(loginUserEmail)
        ref.addSnapshotListener { documentSnapshot, error in
            if let documentSnapshot = documentSnapshot, documentSnapshot.exists,
               let list = try? documentSnapshot.data(as: Follow.self)?.followingUserEmail, list.contains(email) {
                
                
                complete(true)
                
            } else {
                complete(false)
            }
        }
    }
    func startFollowingUser(email: String?){
        guard let loginUserEmail = Auth.auth().currentUser?.email, let email = email else { return }
        db.collection("userList").document(loginUserEmail).updateData([
            "followingUserEmail": FieldValue.arrayUnion([email])
        ])
    }
    func quitFollowingUser(email: String?){
        guard let loginUserEmail = Auth.auth().currentUser?.email, let email = email else { return }
        db.collection("userList").document(loginUserEmail).updateData([
            "followingUserEmail": FieldValue.arrayRemove([email])
        ])
    }
    
    // MARK: postListVC
    func addToLike(postId: String) {
        
        let postRef = db.collection("post").document(postId)
        let newLikeBy: [String: Any] = ["userEmail": currentLoginUserEmail!]
        postRef.updateData(["likeByUsers": FieldValue.arrayUnion([newLikeBy])]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                //self.collectionView.reloadData()
            }
        }
        
    }
    
    func removeLike(postId: String) {
        let postRef = db.collection("post").document(postId)
        let newLikeBy: [String: Any] = ["userEmail": currentLoginUserEmail!]
        postRef.updateData(["likeByUsers": FieldValue.arrayRemove([newLikeBy])]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                //self.collectionView.reloadData()
            }
        }
    }
    
    func getPostsForPostListVC(completion: @escaping (_ posts: [Post], _ postsIds:[String], _ snapshot: QuerySnapshot) -> Void){
       
        // Create a query against the collection.
        let postRef = db.collection("post")
        
        let query = postRef.whereField("userEmail", isNotEqualTo: currentLoginUserEmail!).order(by: "userEmail").order(by: "timestamp", descending: true)
        listener = query
            .addSnapshotListener { documentSnapshot, error in
                
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
               
                
                let posts = document.documents.map { QueryDocumentSnapshot -> Post  in
                    
                    guard let post = try? QueryDocumentSnapshot.data(as: Post.self) else {
                        fatalError("\(String(describing: error?.localizedDescription))")
                    }

                    return post
                }
                
                let postsIds = document.documents.map { QueryDocumentSnapshot -> String in
                    let postId = QueryDocumentSnapshot.documentID
              
                    return postId
                }
                
                completion(posts, postsIds, document)

            }
    }
    func removeListener() {
        listener?.remove()
    }
    // MARK: CommentListVC
    func addComment(commentContent: String, postId: String, complete: @escaping () -> Void) {
        let postRef = db.collection("post").document(postId)

        let newComment: [String: Any] = ["userEmail": currentLoginUserEmail, "commentContent": commentContent]
        print("newComment..\(newComment)")
        
        postRef.updateData([
            "commentList": FieldValue.arrayUnion([newComment])
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                complete()
            }
        }
    }
    
    // MARK: NewArticle Step2 VC
    func uploadNewPost(post: Post, complete: @escaping (_ error: Error?) -> Void) {
        let postRef = db.collection("post").document()
        
        do {
            try postRef
                .setData(from: post)
            complete(nil)
            
            
        }catch let error {
            
            print("Error adding document \(error)" )
            complete(error)
            
        }
        
    }
}
