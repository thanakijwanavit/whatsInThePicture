//
//  UtilityFunctions.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/25/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation

class UtilityFunctions {
    
    static let vggHeight = 224
    static let vggWidth = 224
    
    static func resizeToVgg(image:UIImage) -> UIImage{
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: vggWidth, height: vggHeight))
        return resizedImage
    }
    
    
     static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
