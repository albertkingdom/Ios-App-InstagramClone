//
//  Post.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Codable {
    var imageLink: String?
    var postContent: String?
    var userEmail: String?
    var commentList: [Comment]?
    @ServerTimestamp var timestamp: Timestamp?
}


struct Comment: Codable {
    var userEmail: String?
    var commentContent: String?
}
