//
//  NewsHeaderCell.swift
//  NewsApp
//
//  Created by sude on 22.07.2024.
//

import UIKit

class NewsHeaderCell: UICollectionViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var label: UILabel!
    var isLoading: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.text = label.text?.uppercased()
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        
       clickedCategory(isSelected: false)
    }
   
    func clickedCategory(isSelected: Bool){
        if isLoading == false{
            if isSelected {
                label.backgroundColor = .white
                label.textColor = .black
            } else {
                label.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                label.textColor = UIColor(white: 0.5, alpha: 1.0)
            }
        }
    }
    override var isSelected: Bool {
           didSet {
               clickedCategory(isSelected: false)
           }
       }
}
