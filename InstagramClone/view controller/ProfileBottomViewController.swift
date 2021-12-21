//
//  ProfileBottomViewController.swift
//  InstagramClone
//
//  Created by Albert Lin on 2021/12/20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ProfileBottomViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var collectionView: UICollectionView!
    
    var singleUserPostIdList: [String] = []
    var singleUserPostList: [Post] = []
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
    }
    

    private func generateLayout() -> UICollectionViewLayout {
        //let spacing: CGFloat = 20
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        //        section.contentInsets = NSDirectionalEdgeInsets(top: 400, leading: 0, bottom: 0, trailing: 0)
        //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
        
    }

    
    
    
    
}

extension ProfileBottomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singleUserPostList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postInProfileCollectionViewCell", for: indexPath) as! PostInProfileCollectionViewCell
        cell.configure(with: singleUserPostList[indexPath.row])
        return cell
    }
}
