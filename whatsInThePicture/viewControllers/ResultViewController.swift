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
    
    
    override func viewDidLoad() {
        if addingImage{
            makeNewPhoto()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        photoModel = getFetchedObject()
        if let imageData = photoModel?.imageData{
            imageView.image = UIImage(data: imageData)
        } else {
            debugPrint("photo doesnt exist")
        }
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
}
