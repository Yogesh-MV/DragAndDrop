//
//  CustomViewController.swift
//  DragAndDropSample
//
//  Created by Yogesh Murugesh on 13/10/17.
//  Copyright © 2017 Mallow Technologies. All rights reserved.
//

import UIKit
import MobileCoreServices

class CustomViewController: UIViewController {

    @IBOutlet var dragImageView: UIImageView!
    @IBOutlet var dragTextView: UITextView!
    @IBOutlet var dropImageViewLabel: UILabel!
    @IBOutlet var dropImageView: UIImageView!
    @IBOutlet var dropTextViewLabel: UILabel!
    @IBOutlet var dropTextView: UITextView!
    @IBOutlet var dropOffButton: UIButton!

    
    //MARK:- View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        //Enable User interaction for image view
        dragImageView.isUserInteractionEnabled = true
        dropImageView.isUserInteractionEnabled = true
        
        //Enable Spring load permission for button
        dropOffButton.isSpringLoaded = true// This is to recognise the button when drag interaction hoevr the button
        
        //Add Drag interaction for DragImageView and DrageTextView
        dragImageView.addInteraction(UIDragInteraction(delegate: self))
        dragTextView.addInteraction(UIDragInteraction(delegate: self))

        //Add Drop interaction for DropImageView and DropTextView
        dropImageView.addInteraction(UIDropInteraction(delegate: self))
        dropTextView.addInteraction(UIDropInteraction(delegate: self))
        
        dropImageView.layer.borderWidth = 1
        dropImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        dropTextView.layer.borderWidth = 1
        dropTextView.layer.borderColor = UIColor.lightGray.cgColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Custom Action Methods
    
    @IBAction func showDopOffLocationButtonPressed(_ sender: Any) {
        dropImageViewLabel.isHidden = false
        dropImageView.isHidden = false
        dropTextViewLabel.isHidden = false
        dropTextView.isHidden = false
    }
    
}

//MARK:- UIDragInteractionDelegate Methods

extension CustomViewController: UIDragInteractionDelegate {
    // This method is used to drag the item
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if let textValue = interaction.view as? UITextView {
            let provider = NSItemProvider(object: textValue.text! as NSString)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        } else if let imageView = interaction.view as? UIImageView {
            guard let image = imageView.image else { return [] }
            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        return []
    }
    
    
}

//MARK:- UIDropInteractionDelegate Methods

extension CustomViewController: UIDropInteractionDelegate {
    //To Highlight whether the dragging item can drop in the specific area
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let location = session.location(in: self.view)
        let dropOperation: UIDropOperation?
        if session.canLoadObjects(ofClass: String.self) {
            if dropTextView.frame.contains(location) {
                dropOperation = .copy
            } else if  dropImageView.frame.contains(location) {
                dropOperation = .forbidden
            } else {
                dropOperation = .cancel
            }
        } else if session.canLoadObjects(ofClass: UIImage.self) {
            if dropTextView.frame.contains(location) {
                dropOperation = .forbidden
            } else if  dropImageView.frame.contains(location) {
                dropOperation = .copy
            } else {
                dropOperation = .cancel
            }
        } else {
            dropOperation = .cancel
        }
        
        return UIDropProposal(operation: dropOperation!)
    }
    
    //Drop the drag item and handle accordingly
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if session.canLoadObjects(ofClass: String.self) {
            session.loadObjects(ofClass: String.self) { (items) in
                if let values = items as? [String] {
                    self.dropTextView.text = values.last
                }
            }
        } else if session.canLoadObjects(ofClass: UIImage.self) {
            session.loadObjects(ofClass: UIImage.self) { (items) in
                if let images = items as? [UIImage] {
                    self.dropImageView.image = images.last
                }
            }
        }
        
    }

}
