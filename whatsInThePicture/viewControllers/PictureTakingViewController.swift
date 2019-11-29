//
//  PictureTakingViewController.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PictureTakingViewController:UIViewController{
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<PhotoModel>!
    var pictureProcessingComplete:Bool?
    var currentImage:UIImage?
    var objectHash:String?
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func completeTakingPhoto(_ sender: UIButton) {
        debugPrint("uploadingStart")
        DispatchQueue.main.async {
            self.imageView.isHidden = true
            self.activityIndicator.startAnimating()
        }
        saveToCoreData { (success, error) in
            guard error == nil else {
                return
            }
            debugPrint("finishedTakingPhotoCalled")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            self.finishedTakingPhoto()
        }
    }
    @IBAction func chageImageNameTapped(_ sender: Any) {
        changeImageName()
    }
    @IBAction func longPressed(_ sender: Any) {
        
        if longPressRecognizer.state == .ended {
            userChooseImage()
        }
    }

    override func viewDidLoad() {
        activityIndicator.stopAnimating()
        pictureProcessingComplete = false
        titleName.text = randomString(length: 5)
        userChooseImage()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        removingFetchedAndDataController()
    }
}



/// general functions
extension PictureTakingViewController{
    func finishedTakingPhoto(){
        let currentViewControllerIndex = navigationController?.viewControllers.count
        let resultViewController = self.navigationController?.viewControllers[currentViewControllerIndex!-2] as! ResultViewController
        resultViewController.pageTitle.text = "Result of picture taken"
        resultViewController.objectHash = self.objectHash
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func saveToCoreData(completion:@escaping (Bool,Error?)->Void){
        let photoObject = PhotoModel(context: dataController.viewContext)
        photoObject.imageData = self.currentImage?.pngData()
        photoObject.creationDate = Date()
        photoObject.classificationResult = "waiting for classification"
        photoObject.name = self.titleName.text
        photoObject.objectHash = randomString(length: 20)
        self.objectHash = photoObject.objectHash
        debugPrint("objecthash is \(String(describing: photoObject.objectHash))")
        AWSClientFunctions.convertAndUploadToS3(imageToScaleAndUpload: self.currentImage!, filename: photoObject.objectHash!) { (s3Path, scaledImage, error) in
            guard error == nil else {
                debugPrint("error uploading item \(error.debugDescription)")
                completion(false, error)
                return
            }
            photoObject.s3Path = s3Path
            photoObject.resizedImage = scaledImage?.pngData()
            AWSClientFunctions.getPredictionResult(s3Path: s3Path!) { (predictionResult, error) in
                guard error != nil else {
                    debugPrint("prediction request Error \(error.debugDescription)")
                    return
                }
                if predictionResult == nil {
                    debugPrint("Prediction has not yield any result somwthing is wrong")
                }
                photoObject.classificationResult = predictionResult
                do {
                    try self.dataController.viewContext.save()
                    completion(true, nil)
                } catch {
                    debugPrint("error saving \(error.localizedDescription)")
                    completion(false, error)
                }
            }
        }
    }
    
    
    
    fileprivate func changeImageName() {
        // create and add textfield
        var textField:UITextField?
        let alert = UIAlertController(title: "Image Name", message: "please enter image name", preferredStyle: .alert)
        alert.addTextField { (addedTextField) in
            addedTextField.placeholder = "usefull placeholder"
            addedTextField.clearButtonMode = .whileEditing
            addedTextField.borderStyle = .none
            textField = addedTextField
            ///
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (pAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
            let inputValue = textField?.text
            self.titleName.text = inputValue
            alert.dismiss(animated: true, completion: nil)
        }))
        
        // show alert controller
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // generate random string
    func randomString(length:Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomCharacters = (0..<length).map{_ in characters.randomElement()!}
        let randomString = String(randomCharacters)
        return randomString
    }
}



extension PictureTakingViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage
            else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
        DispatchQueue.main.async {
            self.imageView.image = image
            self.currentImage = image
        }
        pictureProcessingComplete = true
    }
    
}


//Fetching data coredata functions
extension PictureTakingViewController{
    
    //cleaning up
    
    fileprivate func removingFetchedAndDataController() {
        if let pictureProcessingComplete = pictureProcessingComplete{
            if pictureProcessingComplete{
                dataController = nil
                fetchedResultsController = nil
                debugPrint("removing fetchedResultsController and dataController from pictureTakingViewController, Picture processing has completed")
            }
        } else {
            dataController = nil
            fetchedResultsController = nil
            debugPrint("removing fetchedResultsController and dataController from pictureTakingViewController, navigation back button was activated")
        }
    }
    
    //imagepicking
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func userChooseImage(){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: false, completion: nil)
    }
}

