//
//  StoryViewController.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/7.
//

import UIKit

// Not currently used

class StoryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var postData: [Post] = [Post()] {
        didSet {
            //collectionView.reloadData()
            collectionView.collectionViewLayout = generateLayout()

            downloadAllImages()
        }
    }
    var imagesList: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("StoryViewController viewDidLoad")
        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "storyCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.showsHorizontalScrollIndicator = false
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("StoryViewController viewWillAppear")
    }

    private func generateLayout() -> UICollectionViewLayout {
                
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        //item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: 0, trailing: spacing)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
       
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        return UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
    }
    func downloadAllImages()  {
        let dispatchGroup = DispatchGroup()
        for post in postData {
            dispatchGroup.enter()
            downloadImage(url: post.imageLink ?? "", completion: { data in
                DispatchQueue.main.async {
                    self.imagesList.append(UIImage(data: data)!)
                }
                dispatchGroup.leave()
            })
            dispatchGroup.wait()
        }
        dispatchGroup.notify(queue: .main) {
            print("StoryViewController complete download all image")
            //print(self.imagesList)
            print("StoryViewController post.count= \(self.postData.count)...image.count=\(self.imagesList.count)")
            self.collectionView.reloadData()

        }
      
    }
}

extension StoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postData.count == imagesList.count ? postData.count : 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoryCollectionViewCell
        //cell.configure(with: postData[indexPath.row])
        cell.setup(with: imagesList[indexPath.row])
        return cell
        
    }
}

extension StoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "storyDetailVC") as! StoryDetailViewController
        detailVC.modalTransitionStyle = .crossDissolve
        detailVC.modalPresentationStyle = .fullScreen
        
        var dataToPass: [Post] = []
        for (i, post) in self.postData.enumerated(){
            if i >= indexPath.row {
                dataToPass.append(post)
            }
        }
//        detailVC.postData = dataToPass
        detailVC.postData = self.postData
        detailVC.imagesList = self.imagesList
        detailVC.currentImageIndex = indexPath.row




        present(detailVC, animated: true, completion: nil)



    }
}
