//
//  FavouritesFileviewTableViewCell.swift
//  DataOrganizer
//
//  Created by VC on 05/04/24.
//

import UIKit

class FavouritesFileviewTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "FavouritesFileviewTableViewCell"

    @IBOutlet var superView: UIView!
    @IBOutlet var colourView: UIView!
    @IBOutlet var coloursNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colourView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
