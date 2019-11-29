//
//  OverviewViewController.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class OverviewViewController: UIViewController{
    

    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    var fetchedResultsController:NSFetchedResultsController<PhotoModel>!
    var dataController: DataController!
    var selectedPhotoModel: PhotoModel?
    var editMode: Bool = false
    let debugMode = true
    
    
    @IBAction func addImage(_ sender: Any) {
        addImage()
    }
    
    @IBAction func editModeSelected(_ sender: Any) {
        editMode = !editMode
        if editMode {
            self.view.backgroundColor = .darkGray
            self.photoCollection.backgroundColor = .darkGray
        } else {
            self.view.backgroundColor = .white
            self.photoCollection.backgroundColor = .white
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPhotoCells()
        appTitle.text = "What's in my picture"
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUI()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super .setEditing(editing, animated: animated)
        setEditing(editMode, animated: true)
    }

    
    fileprivate func reloadUI() {
        setUpFetchResultsController()
        photoCollection.reloadData()
    }
}

extension OverviewViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(photo,debug: self.debugMode)
        cell.viewContext = dataController.viewContext
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
}

/// set up coredata stuff
extension OverviewViewController: NSFetchedResultsControllerDelegate{
    
    
    fileprivate func setUpFetchResultsController(){
        let fetchRequest: NSFetchRequest<PhotoModel> = PhotoModel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        NSFetchedResultsController<PhotoModel>.deleteCache(withName: "photoModel")
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photoModel")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error fetching data \(error.localizedDescription)")
        }
    }
    
    
    
    fileprivate func setUpPhotoCells() {
        photoCollection.delegate = self
        photoCollection.dataSource = self
    }
}

//Segue actions
extension OverviewViewController{
    fileprivate func addImage(){
        performSegue(withIdentifier: "addNewImage", sender: "addImage")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewImage"{
            let destination = segue.destination as! ResultViewController
            destination.dataController = self.dataController
            destination.fetchedResultsController = self.fetchedResultsController
            destination.loadingResult = false
            if sender as! String == "addImage"{
                destination.addingImage = true
                debugPrint("adding Image")
            } else {
                destination.addingImage = false
                if let selectedPhotoModel = self.selectedPhotoModel{
                    destination.objectHash = selectedPhotoModel.objectHash
                }
                debugPrint("viewing Image")
            }
        }
    }
    
    
    
}


extension OverviewViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.editMode {
            let selectedPhotoModel = fetchedResultsController.object(at: indexPath)
            self.selectedPhotoModel = selectedPhotoModel
            performSegue(withIdentifier: "addNewImage", sender: "viewImage")
        } else {
            let selectedPhotoToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(selectedPhotoToDelete)
            do { try dataController.viewContext.save()
            } catch {
                print("saving error \(error.localizedDescription)")
            }
            print("image removed from memory")
            reloadUI()
        }
    }
}


//extension OverviewViewController:NSFetchedResultsControllerDelegate{
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        photoCollection.endEditing(false)
//    }
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        photoCollection.editing
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .delete:
//            photoCollection.deleteItems(at: [indexPath!])
//            print("delete is called")
//        case .insert:
//            photoCollection.insertItems(at: [newIndexPath!])
//            print("insert is called")
//        default:
//            break
//        }
//    }
//    
//}
