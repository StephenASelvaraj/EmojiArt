//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Stephen Selvaraj on 10/16/18.
//  Copyright © 2018 Stephen Selvaraj. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate,UIScrollViewDelegate,
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
   
    
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // interested in URL or Image to be dropped in the dropzone
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //accept new image from outside and copy it
        //Green + sign appears when the image is dragged for .copy operation
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher =  ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtBackgroundImage = image
            }
            
        }
    
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
            
        }
        
        session.loadObjects(ofClass: UIImage.self) { nsimage in
            if let image = nsimage.first as? UIImage {
                self.imageFetcher.backup = image
            }
            
        }
    }
    
    var imageFetcher: ImageFetcher!
    
    var emojiArtView = EmojiArtView()
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    var emojiArtBackgroundImage : UIImage? {
        get {
            return emojiArtView.backGroundImage
        }
        set {
            scrollView?.zoomScale = 1.0
            emojiArtView.backGroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            // set up the frame size 
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            
            if let dropZone = self.dropZone, size.width > 0 , size.height > 0 {
                scrollView?.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // the contants of these constrains can not be changed at design mode, so we're changing it here in code
        
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet{
            //set the datasource and delegate to self as soon as you have the collection view
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            
            //for the cells to be draggable, make yourself self to implement drag methods
            emojiCollectionView.dragDelegate = self
            
            // For dropping cells
            emojiCollectionView.dropDelegate = self
        }
    }
    
    //map takes the collection of strings and make it into array of strings below
    var emojis = "🐝🦁🍎🍊⚽️🕷🦆🦗🕸🦋🐌🐞🦂🐒🐷🦊🐛🐅🐠🐍".map { String($0) }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let text  = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
            emojiCell.label.attributedText = text
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView // setting up session context to know whether the drag is within the collectionview
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexpath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCollectionView.cellForItem(at: indexpath) as? EmojiCollectionViewCell)?.label.attributedText {
            // item provider here is a local object, unlike the url we called in earlier drag, no need of async queue
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return[dragItem]
        } else {
            //if we couldnt get item attributed string from the cell, return empty dragitem
            return []
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        return UICollectionViewDropProposal.init(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
            
       
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        //this is where we are dropping. set it to default indexpath if the destination is not chosen by user correctly
        let destionationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            // within collection view
            if let sourceIndexPath = item.sourceIndexPath  { //local drag
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    collectionView.performBatchUpdates( { // batch update is used for updating model and collectionview together as a batch so that they are not out of sync.
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destionationIndexPath.item)
                        // do not reload data when we are in the middle of the drag. instead update the collection view
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destionationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destionationIndexPath) // this does actual drop, + sign goes away
                }
   
            } else { // this is not a local drag. It comes from outside your collection vewi
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destionationIndexPath, reuseIdentifier: "DropPlaceHolderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                        placeholderContext.commitInsertion(dataSourceUpdates: { (insertionIndexpath) in
                            self.emojis.insert(attributedString.string, at: insertionIndexpath.item)
                            })
                        } else { // if there is error in getting string, delete the placeholder
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}
