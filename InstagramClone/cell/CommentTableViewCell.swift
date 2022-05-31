//
//  CommentTableViewCell.swift
//  InstagramClone
//
//  Created by 林煜凱 on 5/25/22.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        email.font = .boldSystemFont(ofSize: 14)
    }
    
    func configure(with comment: Comment ) {
        email.text = comment.userEmail
        commentContent.text = comment.commentContent
    }
    
    
}
