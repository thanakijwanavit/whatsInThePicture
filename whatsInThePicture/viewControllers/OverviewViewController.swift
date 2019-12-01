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
    var debugMode = true
    var imageToDeleteIndexPath : IndexPath?
    
    @IBOutlet weak var debugModeButton: UISwitch!
    
    
    @IBAction func changeDebugMode(_ sender: Any) {
        debugMode = debugModeButton.isOn
        UserDefaults.standard.set(debugMode, forKey: "debugMode")
        reloadUI()
    }
    
    
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
        self.debugMode = UserDefaults.standard.bool(forKey: "debugMode")
        
//        AWSClientFunctions.doInvokeAPI3()
        
        appTitle.text = "What's in my picture"

    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        if let imageToDeleteIndexPath = imageToDeleteIndexPath {
            deleteImage(indexPath: imageToDeleteIndexPath)
        }
        setUpPhotoCells()
        self.reloadUI()
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setEditing(editMode, animated: true)
    }

    
    fileprivate func reloadUI() {
        setUpFetchResultsController()
        photoCollection.reloadData()
    }
}

extension OverviewViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        debugPrint("number of objects in section is \(fetchedResultsController.sections?[section].numberOfObjects ?? 0)")
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
        return self.fetchedResultsController.sections?.count ?? 1
    }
}

/// set up coredata stuff
extension OverviewViewController: NSFetchedResultsControllerDelegate{
    

    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.photoCollection.deleteItems(at: [indexPath!])
            print("delete is called")
        case .insert:
            self.photoCollection.insertItems(at: [newIndexPath!])
            print("insert is called")
        default:
            break
        }
    }
    
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


extension OverviewViewController:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? OverviewViewController {
            controller.photoCollection.reloadData()
        }
    }
    
    func deleteImage(indexPath:IndexPath){
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
