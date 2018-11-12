//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Stephen Selvaraj on 10/16/18.
//  Copyright © 2018 Stephen Selvaraj. All rights reserved.
//

import UIKit

// Revisit below two methods and understand

protocol EmojiArtViewDelegate: class {
    func emojiArtViewDidChange(_ sender: EmojiArtView)
}

extension Notification.Name {
    static let EmojiArtViewDidChange = Notification.Name("EmojiArtViewDidChange")
}

class EmojiArtView: UIView, UIDropInteractionDelegate
{

    weak var delegate: EmojiArtViewDelegate?
    
    var backGroundImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
        
    }
     override func draw(_ rect: CGRect) {
        // Drawing code
        backGroundImage?.draw(in: bounds)
    }
    
    // 2 inits below CGRect and NSCoder needs to be overridden
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { provider in
            let dropPoint = session.location(in: self)
            for attributedString in provider as? [NSAttributedString] ?? [] {
                self.addLabel(with: attributedString, centeredat: dropPoint)
            }
        }
    }
    
    func addLabel(with attributedString: NSAttributedString, centeredat point:CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label) // for recognizing different gestures like pinching, paning etc
        addSubview(label)
    }
    
  
    
}


