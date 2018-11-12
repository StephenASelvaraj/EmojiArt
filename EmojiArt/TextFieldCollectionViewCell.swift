//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Stephen Selvaraj on 11/7/18.
//  Copyright © 2018 Stephen Selvaraj. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    var resignationHandler: (() -> Void)? //optional
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //talk to collectionview thru closure
        resignationHandler?()
    }
    
    // delegate method of text field
    func  textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //keyboard disappears
        textField.resignFirstResponder
        return true
    }
    
}
