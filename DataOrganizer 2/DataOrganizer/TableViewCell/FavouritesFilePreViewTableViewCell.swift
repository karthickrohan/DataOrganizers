//
//  FavouritesFilePreViewTableViewCell.swift
//  DataOrganizer
//
//  Created by VC on 05/04/24.
//

import UIKit

class FavouritesFilePreViewTableViewCell: UITableViewCell {

    static let cellIdentifier = "FavouritesFilePreViewTableViewCell"
    
    @IBOutlet var superView: UIView!
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var separateView: UIView!
    @IBOutlet var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(image: UIImage?,date: Date, fileType: String) {
       
        imageIcon.image = image
        nameLabel.text = "img"
        createDate(date: date)
        //getFileImage(fileType: fileType, image: image)
    }
    
    func createDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        dateLabel?.text = dateFormatter.string(from: date)
    }
    
    
    
    func getFileImage(fileType: String ,date: Date)  {
        createDate(date: date)
        switch fileType {
        case "pdf":
            imageIcon.image = UIImage(named: "v2_file_pdf")
        case "ppt", "pptx":
            imageIcon.image = UIImage(named: "v2_file_ppt")
        case "doc", "docx":
            imageIcon.image = UIImage(named: "v2_file_doc")
        case "xls", "xlsx":
            imageIcon.image = UIImage(named: "v2_file_xls")
        default:
            imageIcon.image = UIImage(named: "v2_file_doc")
        }
    }
    
}
