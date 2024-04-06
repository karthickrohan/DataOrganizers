//
//  FilePreViewViewController.swift
//  DataOrganizer
//
//  Created by VC on 02/04/24.
//

import UIKit
import Foundation
import CoreData

class FilePreViewViewController: UIViewController ,StoryboardInstantiable ,UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate{
    
    
    
    static var storyboardName: String = "FilePreViewViewController"
    
    @IBOutlet var fileSuperView: UIView!
    @IBOutlet var fileTableView: UITableView!
    
    private var searchController: UISearchController?
    var filePreViewViewModel = FilePreViewViewModel()
    private var fetchedResultsController: NSFetchedResultsController<FileManager>!
    
    var getFolderID = String()
    var initialFetchResult = [FileManager]()
    var folderName = String()
    var filteredFolders: [FolderData] = []
    var foldersData: [FolderData] = []
    var dataManager = DataBaseHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileTableView.dataSource = self
        fileTableView.delegate = self
        searchController?.delegate = self
        setUpTableView()
        setNavigationButtons()
        setNavigationLeftBarButton()
        setupSearchOnNavigationbar()
        initializeFetchedResultsController(searchText: "", folderID: getFolderID, index: 0)
        loadingData()
        fileTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        fileTableView.separatorColor = UIColor.clear
        self.navigationItem.title = folderName
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    
    
    func initializeFetchedResultsController(searchText: String, folderID: String,index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        
        let moc = appDelegate.persistentContainer.viewContext
        let entityName = "FileManager"
        
        let fetchRequest = NSFetchRequest<FileManager>(entityName: entityName)
        
        let fileNameSortDescriptor = NSSortDescriptor(key: "imagedate", ascending: true)
        let sortDescriptors = [fileNameSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsDistinctResults = true
        
        let folderPredicate = NSPredicate(format: "folderaID == %@", folderID)
        var predicates = [folderPredicate]
        
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "filename CONTAINS[c] %@", searchText)
            predicates.append(searchPredicate)
        }
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            fileTableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    
    
    func setUpTableView() {
        fileTableView.register(UINib(nibName: FilePreViewTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: FilePreViewTableViewCell.cellIdentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hexString: "#FBFBFD")
        appearance.shadowColor = UIColor(hexString: "#D3D6DE")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = nil
    }
    
    func setupSearchOnNavigationbar() {
        if self.navigationItem.searchController == nil {
            
            searchController = UISearchController(searchResultsController: nil)
            self.navigationItem.searchController = searchController
            
            searchController?.delegate = self
            searchController?.searchBar.delegate = self
            searchController?.searchBar.showsBookmarkButton = false
            
        }
        self.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func setNavigationLeftBarButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "ios Back (1)"), for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(pressedBackButton), for: .touchUpInside)
        backButton.sizeToFit()
        let customView = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItems = [customView]
    }
    
    @objc func pressedBackButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func setNavigationButtons() {
        let profileBtn = UIButton(type: .custom)
        if let image = UIImage(named: "galleryiconnew 1") {
            let scaledImage = image.resized(to: CGSize(width: 32.0, height: 32.0))
            profileBtn.setImage(scaledImage, for: .normal)
        }
        let barButtonItem3 = UIBarButtonItem(customView: profileBtn)
        profileBtn.addTarget(self, action: #selector(moveToImagePickerController), for: .touchUpInside)
        
        let doucumentButton = UIButton(type: .custom)
        if let image = UIImage(named: "filemoveicon") {
            let scaledImage = image.resized(to: CGSize(width: 36.0, height: 36.0))
            doucumentButton.setImage(scaledImage, for: .normal)
        }
        let doucumentBarButton = UIBarButtonItem(customView: doucumentButton)
        doucumentButton.addTarget(self, action: #selector(openDocumentPicker), for: .touchUpInside)
        self.navigationItem.rightBarButtonItems = [doucumentBarButton,barButtonItem3]
    }
    
    func loadingData() {
        initialFetchResult = filePreViewViewModel.getAllData(folderID: getFolderID)
        
        if !initialFetchResult.isEmpty {
            foldersData = filteredFolders
            filteredFolders = foldersData
            fileTableView.reloadData()
        }
    }

    
    @objc func moveToImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc func openDocumentPicker() {
        if #available(iOS 14.0, *) {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .fullScreen
            present(documentPicker, animated: true, completion: nil)
        } else {
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .fullScreen
            present(documentPicker, animated: true, completion: nil)
        }
        
    }
    
}



extension FilePreViewViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        initialFetchResult = filePreViewViewModel.getAllData(folderID: getFolderID)
        return initialFetchResult.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FilePreViewTableViewCell", for: indexPath) as? FilePreViewTableViewCell {
            initialFetchResult = filePreViewViewModel.getAllData(folderID: getFolderID)
            cell.fileNameLabel.text = "Welcome"
            cell.isUserInteractionEnabled = true
            
            guard indexPath.row < initialFetchResult.count else {
                return UITableViewCell()
            }
            
            let item = initialFetchResult[indexPath.row]
            cell.itemID = item.fileuniqueid
            cell.isFavorite = item.isfavourite
            cell.folderid = item.folderaID
            cell.filename = item.filename
           
            
            
            if let imageData = item.savedimage as Data?, let image = UIImage(data: imageData) {
                cell.fileImageView?.image = image
                cell.fileNameLabel?.text = item.imagename
                cell.imageDta = imageData
                if let colorData = item.addfavouritecolour as Data?, let color = UIColor.color(from: colorData) {
                    cell.colourView.backgroundColor = color
                } else {
                    cell.colourView.backgroundColor = UIColor.clear
                }
                cell.configure(image: image, date: item.imagedate ?? Date(), fileType: item.filetype ?? "")
            } else {
                if let fileData = item.filedata as Data?, let fileType = item.filetype {
                    cell.fileNameLabel?.text = item.filename
                    cell.fileDta = item.imagetime
                    if let colorData = item.addfavouritecolour as Data?, let color = UIColor.color(from: colorData) {
                        cell.colourView.backgroundColor = color
                    } else {
                        cell.colourView.backgroundColor = UIColor.clear
                    }
                    
                    cell.getFileImage(fileType: item.filetype ?? "", date: item.imagedate ?? Date())
                }
            }
            
            if let searchText = searchController?.searchBar.text, !searchText.isEmpty {
                if let filename = item.filename {
                    let attributedString = NSMutableAttributedString(string: filename)
                    let range = (filename as NSString).range(of: searchText, options: .caseInsensitive)
                    
                    if range.location != NSNotFound {
                        attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
                        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.length))
                        cell.fileNameLabel.attributedText = attributedString
                    } else {
                        cell.fileNameLabel.text = filename
                    }
                }
            }

            
            if indexPath.row == fileTableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.separateView.isHidden = true
            } else {
                cell.separateView.isHidden = false
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = pickerImage.pngData() {
            dismiss(animated: true) {
                let itemID = self.generateUniqueID()
                self.filePreViewViewModel.savingImageCoreData(imageData: imageData as NSData, folderID: self.getFolderID,itemID: itemID)
                self.fileTableView.reloadData()
            }
        }
    }
    
    func generateUniqueID() -> String {
        var id = ""
        var CheckFolderID = Bool()
        repeat {
            let randomID = String(format: "%04d", arc4random_uniform(10000))
            id = randomID
            CheckFolderID = filePreViewViewModel.isUniqueFileID(fileID: id)
        } while !CheckFolderID
        return id
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        print("Selected file URL: \(selectedFileURL)")
        let documentID = generateUniqueID()
        filePreViewViewModel.saveFile(fileURL: selectedFileURL,folderID: getFolderID,fileID: documentID)
        fileTableView.reloadData()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

protocol StoryboardInstantiable {
    static var storyboardName: String { get }
    
    static func instantiateFromStoryboard() -> Self
}

extension StoryboardInstantiable where Self: UIViewController {
    static func instantiateFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardName) as? Self else {
            fatalError("Failed to instantiate view controller from storyboard.")
        }
        return viewController
    }
}

extension FilePreViewViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.returnKeyType = .done
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func filterFolders(for searchText: String) {
        if searchText.isEmpty {
            filteredFolders = foldersData
        } else {
            filteredFolders = foldersData.filter { $0.foldername?.lowercased().contains(searchText.lowercased()) ?? false }
        }
        fileTableView.reloadData()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFolders(for: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filterFolders(for: "")
        searchBar.resignFirstResponder()
    }
    func loadData() {
        initialFetchResult = filePreViewViewModel.getAllData(folderID: getFolderID)
    }

   

    
    
}


extension UIColor {
    
    static func color(from data: Data) -> UIColor? {
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        } catch {
            print("Error unarchiving color data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func encode() -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        } catch {
            print("Error encoding color data: \(error.localizedDescription)")
            return nil
        }
    }
}

