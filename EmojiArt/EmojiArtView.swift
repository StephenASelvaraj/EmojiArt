//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Stephen Selvaraj on 10/16/18.
//  Copyright © 2018 Stephen Selvaraj. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {

   
    var backGroundImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
        
    }
     override func draw(_ rect: CGRect) {
        // Drawing code
        backGroundImage?.draw(in: bounds)
    }
 

}
