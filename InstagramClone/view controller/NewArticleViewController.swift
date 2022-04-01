//
//  NewArticleViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/10/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Photos

class NewArticleViewController: UIViewController {
    var db: Firestore!
    var isSelectImage = false
    var allPhotos: PHFetchResult<PHAsset>? //photos from iphone

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func touchCameraButton() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBAction func clickCancel(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    @IBAction func touchNextStepButton() {
        if isSelectImage {
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "NewArticleStep2VC") as! NewArticleStep2ViewController
            nextVC.image = self.postImage.image
            navigationController?.pushViewController(nextVC, animated: true)
            
        } else {
            let alertC = UIAlertController(title: nil, message: "請選取照片！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alertC.addAction(okAction)
            present(alertC, animated: true, completion: nil)
        }
       
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        print("NewArticleViewController viewDidLoad")
        // Do any additional setup after loading the view.
        
//        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.pickImage))
//        postImage.addGestureRecognizer(tapGR)
//        postImage.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem?.title = "Next"

        
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        // check camera availibility
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = true
        } else {
            cameraButton.isEnabled = false
        }
        
    }
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("UIImageView tapped")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        //getPhotos()
        
//        let fetchOption = PHFetchOptions()
//        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOption)
//        collectionView.reloadData()
        requestAuthorization {
            self.fetchPhotos()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        postImage.image = UIImage(systemName: "photo")
    }
    func fetchPhotos() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOption)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    func requestAuthorization(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                completion()
            }
        }
    }
}
extension NewArticleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // implement methods in UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            postImage.image = image
            isSelectImage = true
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension NewArticleViewController: UICollectionViewDataSource {
    
    
    private func generateLayout() -> UICollectionViewLayout {
        //let spacing: CGFloat = 20
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
       
        //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multipleImageCell", for: indexPath) as! MultipleImageLoaderCollectionViewCell
        let asset = allPhotos?.object(at: indexPath.row)
        cell.imageView.fetchImage(asset: asset!, targetSize: cell.imageView.frame.size)
       
        return cell
    }
    
   
}
extension NewArticleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = allPhotos?.object(at: indexPath.row)
        postImage.fetchImage(asset: asset!, targetSize: postImage.frame.size)
        isSelectImage = true
    }
}

extension UIImageView {
    // fetch image based on PHFetchResult
    func fetchImage(asset: PHAsset, targetSize: CGSize) {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
            if let image = image {
               
                self.image = image
            } else {
                print("error asset to image")
            }
        }
        
    }
}
