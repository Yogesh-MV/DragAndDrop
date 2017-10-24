//
//  CustomTableViewController.swift
//  DragAndDropSample
//
//  Created by Yogesh Murugesh on 13/10/17.
//  Copyright © 2017 Mallow Technologies. All rights reserved.
//

import UIKit

class CustomTableViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!

    var stringArray = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
    
    //MARK:- View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        textView.addInteraction(UIDragInteraction(delegate: self))
        textField.addInteraction(UIDragInteraction(delegate: self))
        tableView.dropDelegate = self
        tableView.dragDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK:- UITableViewDataSource Methods

extension CustomTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = stringArray[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

//MARK:- UIDragInteractionDelegate Methods

extension CustomTableViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        var text: String?
        if let textValue = interaction.view as? UITextView {
            text = textValue.text
        } else if let textValue = interaction.view as? UITextField {
            text = textValue.text
        }
        if text != nil {
            let provider = NSItemProvider(object: text! as NSString)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        return []
    }
    
}

//MARK:- UIDropInteractionDelegate Methods

extension CustomTableViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
}

//MARK:- UITableViewDragDelegate Methods

extension CustomTableViewController: UITableViewDragDelegate {
    //from tableView item gets dragged from here
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let string = stringArray[indexPath.row]
        let itemProvider = NSItemProvider(object: string as NSString)
        return [UIDragItem(itemProvider: itemProvider)]
    }
}


//MARK:- UITableViewDropDelegate Methods

extension CustomTableViewController: UITableViewDropDelegate {
    //Check whether tableview can load this object or not
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    //Copy the contenet in tablview drop
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .copy, intent: .automatic)
    }
    
    //Once dropped specific indexpath are get inserted
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { (items) in
            if let values = items as? [String] {
                var indexPathArray = [IndexPath]()
                for (index, item) in values.enumerated() {
                    let indexPath = IndexPath(row: destinationPath.row + index, section: destinationPath.section)
                    self.stringArray.insert(item, at: indexPath.row)
                    indexPathArray.append(indexPath)
                }
                
                tableView.insertRows(at: indexPathArray, with: .automatic)
            }
        }
    }
}
