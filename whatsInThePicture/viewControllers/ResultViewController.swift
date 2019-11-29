//
//  ResultViewController.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ResultViewController:UIViewController{
    var addingImage:Bool!
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<PhotoModel>!
    var loadingResult:Bool!
    var objectHash: String?
    var photoModel: PhotoModel?
    
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationResultLabel: UILabel!
    
    
    
    //debug bbutton for testing uploading image
    
    @IBOutlet weak var uploadDataButton: UIButton!
    
    
    
    
    @IBAction func uploadDataButtonClicked(_ sender: Any) {
//        convertAndUploadToS3()
    }
    
    override func viewDidLoad() {
        if addingImage{
            makeNewPhoto()
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        photoModel = getFetchedObject()
        
        //check for classification result and s3 path
        if photoModel?.classificationResult == "waiting for classification" {
            if photoModel?.s3Path == nil {
                
                guard photoModel != nil else {
                    debugPrint("photoModel doesnt exist. data is corrupted please delete the image")
                    return
                }
                if let photoModel = photoModel {
                    AWSClientFunctions.convertAndUploadToS3(imageToScaleAndUpload: UIImage(data: photoModel.imageData!)! , filename: photoModel.objectHash!) { (s3Path, scaledImage, error) in
                        guard error == nil else {
                            debugPrint("error uploading item \(error.debugDescription)")
                            return
                        }
                        photoModel.s3Path = s3Path
                        photoModel.resizedImage = scaledImage?.pngData()
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            debugPrint("error saving \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        
        
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !loadingResult{
//            dataController = nil
//            fetchedResultsController = nil
            debugPrint("removing fetchedResultsController and dataController from resultsViewController")
        }
    }
}



// segue


extension ResultViewController{
    fileprivate func makeNewPhoto(){
        loadingResult = true
        performSegue(withIdentifier: "takeNewPhoto", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "takeNewPhoto"{
            
            let destination = segue.destination as! PictureTakingViewController
            destination.dataController = self.dataController
            destination.fetchedResultsController = self.fetchedResultsController
            
            
        }
    }
    
    fileprivate func setUpFetchResultsController(){

        let fetchRequest: NSFetchRequest<PhotoModel> = PhotoModel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        if let objectHash = objectHash {
            let predictate = NSPredicate(format: "objectHash == %@", objectHash)
            fetchRequest.predicate = predictate
        }
        fetchRequest.sortDescriptors = [sortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photoModel")
//        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error fetching data \(error.localizedDescription)")
        }
    }
    
    
    func getFetchedObject()->PhotoModel?{
        setUpFetchResultsController()
        if let photoModels = fetchedResultsController.fetchedObjects{
            for photoModel in photoModels{
                if photoModel.objectHash == self.objectHash {
                    debugPrint("object is found")
                    return photoModel
                }
            }
        }
        debugPrint("object is not found")
        return nil
    }
    
    
    fileprivate func configureUI() {
        pageTitle.text = photoModel?.name
        
        let classificationResult = photoModel?.classificationResult
        if classificationResult != "waiting for classification"{
            debugPrint("classificationResult available \(String(describing: classificationResult))")
            self.classificationResultLabel.text = classificationResult
        } else {
            debugPrint("classificationResult unavailable")
            self.classificationResultLabel.text = "classification result not available"
        }
        
        if let imageData = photoModel?.imageData{
            imageView.image = UIImage(data: imageData)
        } else {
            debugPrint("photo doesnt exist")
        }
        
        // set button name
//        uploadDataButton.setTitle("upload", for: .normal)
    }
}
