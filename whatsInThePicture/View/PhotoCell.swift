//
//  PhotoCell.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoCell:UICollectionViewCell{
    @IBOutlet weak var imageToDisplay: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewContext:NSManagedObjectContext!
    
    
    
    func initWithPhoto(_ photo: PhotoModel,debug: Bool) {
        
        if photo.imageData != nil {
//            print("photo data exist")
            DispatchQueue.main.async {
                
                self.imageToDisplay.image = UIImage(data: photo.imageData! as Data)
                if debug{
                    debugPrint("debugging, displaying aws path")
                    self.title.text = photo.s3Path
                } else {
                    self.title.text = photo.name
                }
                
                self.activityIndicator.stopAnimating()
            }
            
        } else {
            print("photo data doesnt exist")
//            askUserToProvideImage
        }
    }
}

