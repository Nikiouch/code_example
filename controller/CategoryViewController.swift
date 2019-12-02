//
//  CategoryViewController.swift
//  OwlGame
//
//  Created by Никита Главацкий on 06/02/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sectionsCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toolsView: ToolsUIView!
    
    var level: Level!
    var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>?
    var updatedCell: IndexPath?
    var oldScore: Int64?
    var animatedAppear: Bool = true
    
    func dismissChildView(){
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        animatedAppear = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultController!.sections{
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = fetchedResultController!.object(at: indexPath) as! Section
        var cell: CategoryCardCell
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IphoneCategoryCardCell", for: indexPath as IndexPath) as! CategoryCardCell
            cell.categoryNumber.text = "\(indexPath.row + 1)"
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCardCell", for: indexPath as IndexPath) as! CategoryCardCell
            cell.ipadCategoryNumber.text = "\(indexPath.row + 1)"
        }
        
        if level.number == 0 && indexPath.row > 1 {
            cell.changeProImageState(Utils.instance.isFullVersion())
        }
        
        cell.section = section
        return cell
    }

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBAction func backToMenu(_ sender: Any) {
        CoreDataManager.instance.saveContext()
        let parent = self.presentingViewController as! ViewController
        parent.toolsView.updateView()
//        level.score = 80
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if level.number == 0 {
            titleLabel.text = "АЛФАВИТ"
        } else {
            titleLabel.text = "Урок \(level.name ?? "0")"
        }
        
        toolsView.constructView()
        fetchedResultController = level.getSections(level: level)
        fetchedResultController!.delegate = self
        do{
            try fetchedResultController!.performFetch()
        } catch {
            print(error)
        }
        sectionsCollectionView.reloadData()
        let layout = sectionsCollectionView.collectionViewLayout as? CategoryCollectionViewLayout
        layout?.delegate = self
//        let layout = categoryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 20)
//        layout.minimumLineSpacing = 30
//        layout.minimumInteritemSpacing = 20
        // Do any additional setup after loading the view.
        
        //titleLabel.text = "Урок \(level.name ?? "0")"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone && animatedAppear{
            categoryCollectionView.isPagingEnabled = false
            categoryCollectionView.isScrollEnabled = true
//            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
//                var rect = self.sectionsCollectionView.frame
//                rect = rect.offsetBy(dx: rect.width / 10, dy: 0)
//
//                self.sectionsCollectionView.scrollRectToVisible(rect, animated: false)
//            }) { (_) in
//                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//                    var rect = self.sectionsCollectionView.frame
//                    rect = rect.offsetBy(dx: -rect.width / 10, dy: 0)
//                    self.sectionsCollectionView.scrollRectToVisible(rect, animated: true)
//                }, completion: nil)
//
//            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = fetchedResultController?.object(at: indexPath) as? Section
        animatedAppear = false
        
        if level.number == 0 && indexPath.row > 1 && !Utils.instance.isFullVersion(){
            Utils.instance.openSubs(self)
            return
        }
        
        if section!.sectionType == .remember{
            performSegue(withIdentifier: "CategoryToRepeat", sender: section)
        } else {
            if Utils.instance.isConnectedToNetwork() {
                performSegue(withIdentifier: "CategoryToTask", sender: section)
            } else {
                let dialogService = DialogService()
                let alert = dialogService.connectionAlert(completion: {
                    self.performSegue(withIdentifier: "CategoryToTask", sender: section)
                })
                present(alert, animated: true)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CategoryToRepeat":
            let viewController = segue.destination as! RepeatViewController
            viewController.section = sender as? Section
            oldScore = (sender as? Section)!.score
        case "CategoryToTask":
            let viewController = segue.destination as! TaskViewController
            viewController.section = sender as? Section
            oldScore = (sender as? Section)!.score
        default:
            print("GG")
        }
    }
   
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            print("GG")
            
        case .delete:
            print("GG")
            
        case .move:
            print("GG")
            
        case .update:
            let cell = sectionsCollectionView.cellForItem(at: indexPath!) as? CategoryCardCell
            let section = fetchedResultController?.object(at: indexPath!) as? Section
            if let oldScore = oldScore{
                if cell?.getStars(forScore: oldScore) != cell?.getStars(forScore: section!.score){
                    updatedCell = indexPath
                    cell?.changed = true
                    cell?.lastScore = oldScore
                } else {
                    updatedCell = nil
                }
            }
            cell?.section = section
            var sum = 0
            for section in (fetchedResultController!.fetchedObjects! as? [Section])!{
                if section.sectionType != .remember{
                    sum += Int(section.score)
                }
            }
            level.score = Int64( Double(sum) / 3.0 )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let updatedCell = updatedCell{
            let cell = categoryCollectionView.cellForItem(at: updatedCell) as? CategoryCardCell
            cell?.animateChange()
            self.updatedCell = nil
        }
    }
}

extension CategoryViewController: CategoryCollectionViewDelegate{
    func theNumberOfItemsInCollectionView() -> Int {
        return 4
    }
}
