//
//  FavoritesViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var discoverCollectionView: UICollectionView!
    var customImageFlowLayout: CustomCollectionViewFlowLayout!
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        
        loadimage()
        
        customImageFlowLayout = CustomCollectionViewFlowLayout()
        discoverCollectionView.collectionViewLayout = customImageFlowLayout
        discoverCollectionView.backgroundColor = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadimage(){
        
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        images.append(UIImage(named : "test")!)
        self.discoverCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = discoverCollectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCell", for: indexPath) as! ImageCollectionViewCell
        let image = images[indexPath.row]
        
        cell.DiscoverImageView.image = image
        
        return cell
        
    }

}
