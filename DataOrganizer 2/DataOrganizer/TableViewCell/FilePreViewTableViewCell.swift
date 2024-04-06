//
//  FilePreViewTableViewCell.swift
//  DataOrganizer
//
//  Created by VC on 02/04/24.
//

import UIKit

protocol MessageActionHandler: AnyObject {
    func handleMessageReply(_ : Any)
}

protocol FilePreViewTableViewCellDelegate: AnyObject {
    func didSelectColor(color: Data?, forItemWithID itemID: String, isFavorite: Bool)
}
protocol ProfileImageOpenDelegate {
    func openImage(referenceView: UIImageView, image: UIImage)
}

var messageActionHandler: MessageActionHandler!
var filePreViewTableViewCellDelegate: FilePreViewTableViewCellDelegate!
var profileImageOpenDelegate: ProfileImageOpenDelegate!

class FilePreViewTableViewCell: UITableViewCell {
    @IBOutlet var fileSuperView: UIView!
    @IBOutlet var fileImageView: UIImageView!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var fileDateLabel: UILabel!
    @IBOutlet var colourView: UIView!
    @IBOutlet var separateView: UIView!
    
    static let cellIdentifier = "FilePreViewTableViewCell"
    var filePreViewViewModel = FilePreViewViewModel()
    var itemID: String?
    var isFavorite: Bool = false
    var uniQueID: String?
    var imageDta : Data?
    var fileDta: String?
    var filename: String?
    var folderid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(contextMenuInteraction)
        colourView.layer.cornerRadius = 6
        colourView.clipsToBounds = true
        fileImageView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(image: UIImage?,date: Date, fileType: String) {
       
        fileImageView.image = image
        fileNameLabel.text = "img"
        createDate(date: date)
    }
    
    func createDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        fileDateLabel?.text = dateFormatter.string(from: date)
    }
    
    
    
    func getFileImage(fileType: String ,date: Date)  {
        createDate(date: date)
        switch fileType {
        case "pdf":
            fileImageView.image = UIImage(named: "v2_file_pdf")
        case "ppt", "pptx":
            fileImageView.image = UIImage(named: "v2_file_ppt")
        case "doc", "docx":
            fileImageView.image = UIImage(named: "v2_file_doc")
        case "xls", "xlsx":
            fileImageView.image = UIImage(named: "v2_file_xls")
        default:
            fileImageView.image = UIImage(named: "v2_file_doc")
        }
    }
    
}

extension FilePreViewTableViewCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.makeContextMenu()
        }
    }
    
    func makeContextMenu() -> UIMenu {
        var actions: [UIAction] = []
        let addFavoriteAction = actionFor(title: "AddFavourite", imageName: "")
        actions.append(addFavoriteAction)
        let submenuActions = makeSubmenu()
        actions.append(contentsOf: submenuActions)
        return UIMenu(title: "", children: actions)
    }

    private func actionFor(title: String, imageName imgName: String, attributes: UIMenuElement.Attributes = [], isFont: Bool = false) -> UIAction {
        let defaultHandler: UIActionHandler = { action in  self.handleContextualAction(action) }
        return UIAction(title: title, image: UIImage(), attributes: attributes, handler: defaultHandler)
    }

    
    private func makeSubmenu() -> [UIAction] {
        var subactions: [UIAction] = []
        let colorMenuActions = makeColorMenu()
        subactions.append(contentsOf: colorMenuActions)
        return subactions
    }
    
    func makeColorMenu() -> [UIAction] {
        var colorActions: [UIAction] = []
        let colorNames = ["Red", "Blue", "Green", "Yellow", "Orange", "Purple", "Cyan", "Magenta", "Brown", "Gray"]
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple, .cyan, .magenta, .brown, .gray]
        for (index, color) in colors.enumerated() {
            let title = colorNames[index]
            let imageSize = CGSize(width: 30, height: 30)
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let image = renderer.image { context in
                let rect = CGRect(origin: .zero, size: imageSize)
                let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: imageSize.width / 2.0)
                color.setFill()
                roundedRect.fill()
            }
            
            let colorAction = UIAction(title: title, image: image) { [weak self] action in
                guard let self = self else { return }
                if let index = colors.firstIndex(of: color) {
                 
                    self.isFavorite = true
                    
                    if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
                        
                        print("itemIDitemID:\(String(describing: itemID))")
                        print("imageDtaimageDta:\(String(describing: imageDta))")
                        print("fileDtafileDta:\(String(describing: fileDta))")
                        
                        let colorNSData = colorData as NSData
                        if fileDta == nil {
                            filePreViewViewModel.saveFavouriteDetailsData(
                                itemID: itemID ?? "",
                                color: colorNSData,
                                isFavorite: true,
                                imageData: imageDta! as NSData,
                                selectedIndex: index,
                                fileName: filename ?? "",
                                folderid: folderid ?? "")
                        } else {
                            filePreViewViewModel.saveFilesData(itemID: itemID!,
                                                                 color: colorNSData,
                                                                 isFavorite: isFavorite, selectedIndex: index,
                                                                 fileName: filename ?? "", folderID: folderid ?? "", fileData: fileDta ?? "")
                        }
                    }
                    
                    self.colourView.backgroundColor = color
                }
                
            }
            colorActions.append(colorAction)
        }
        return colorActions
    }
    
    func handleContextualAction(_ action: UIAction) {
        if action.title == "Choose Color" {
        } else if action.title == "AddFavourite" {
        }
    }
    
  
}
