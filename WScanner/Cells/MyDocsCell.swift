//
//  MyDocsCell.swift
//  WScanner
//
//  Created by webtualApple on 25/01/21.
//

import UIKit

class MyDocsCell: UICollectionViewCell {
    
    @IBOutlet var imgDocument : UIImageView!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var viewDelete : UIView!
    @IBOutlet var btnShare : UIButton!
    @IBOutlet var viewShare : UIView!
    @IBOutlet var viewFileName : UIView!
    @IBOutlet var lblFileName : UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
