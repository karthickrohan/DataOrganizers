//
//  ViewController.swift
//  FileMangerorganizer
//
//  Created by VC on 01/04/24.
//

import UIKit
import Foundation

class ViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate ,UICollectionViewDelegate,UICollectionViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet var superView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    var folders: [String] = []
    var filteredFolders: [FolderData] = []
    var folderID = String()
    private var searchController: UISearchController?
    var folderViewViewModel = FolderViewViewModel()
    var foldersData: [FolderData] = []
    var textFiledName = String()
    var dataManager = DataBaseHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchController?.delegate = self
        self.title = nil
        setNavigationBar()
        setNavigationButtons()
        setUpCollectionViewCell()
        setupSearchOnNavigationbar()
        loadingData()
        dissMissTheTextFieldEditing()
        collectionView.alwaysBounceVertical = true
    }
    

    func setUpCollectionViewCell() {
        collectionView.register(UINib(nibName: "FolderPreViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FolderPreViewCollectionViewCell")
    }
    
    func setNavigationBar() {
        self.title = "FileManager"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func loadingData() {
        if let fetchedFolders = dataManager.fetchFolders() {
            foldersData = fetchedFolders
            filteredFolders = foldersData
            collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "FileManager"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
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
    
    func setUpScrollView() {
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let collectionViewHeight = min(collectionView.contentSize.height, UIScreen.main.bounds.height)
        collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight).isActive = true
        
    }
    
    func setupSearchOnNavigationbar() {
        self.searchController = UISearchController(searchResultsController: nil)
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        searchController?.searchBar.showsBookmarkButton = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setNavigationButtons() {
        
        let favouriteBtn = UIButton(type: .custom)
        if let image = UIImage(named: "favouritesiconnew") {
            let scaledImage = image.resized(to: CGSize(width: 30.0, height: 30.0))
            favouriteBtn.setImage(scaledImage, for: .normal)
        }
        let leftBarButton = UIBarButtonItem(customView: favouriteBtn)
        favouriteBtn.addTarget(self, action: #selector(pressedFavoriteFolder), for: .touchUpInside)
        self.navigationItem.leftBarButtonItems = [leftBarButton]
        
        let profileBtn = UIButton(type: .custom)
        if let image = UIImage(named: "newcriclemenu") {
            let scaledImage = image.resized(to: CGSize(width: 30.0, height: 30.0))
            profileBtn.setImage(scaledImage, for: .normal)
        }
        let barButtonItem3 = UIBarButtonItem(customView: profileBtn)
        profileBtn.addTarget(self, action: #selector(createNewFolder), for: .touchUpInside)
        self.navigationItem.rightBarButtonItems = [barButtonItem3]
    }

    @objc func pressedFavoriteFolder() {
        let favouriteController = FavouritesFileViewViewController.instantiateFromStoryboard()
        favouriteController.navigationItem.title = nil
        self.navigationController?.pushViewController(favouriteController, animated: true)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
       
        collectionView.endEditing(true)
    }
    
    func dissMissTheTextFieldEditing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)

    }
    
    func filterFolders(for searchText: String) {
        if searchText.isEmpty {
            filteredFolders = foldersData
        } else {
            filteredFolders = foldersData.filter { $0.foldername?.lowercased().contains(searchText.lowercased()) ?? false }
        }
        collectionView.reloadData()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFolders(for: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filterFolders(for: "")
        searchBar.resignFirstResponder()
    }
    
    @objc func createNewFolder() {
        let folderName = "untitled folder"
        let folderID = generateUniqueID()
        self.folderViewViewModel.saveFolderCoreData(folderName: folderName, folderID: folderID)
        self.createDirectory(withName: folderName)
        self.collectionView.reloadData()
        DispatchQueue.main.async {
            let lastIndexPath = IndexPath(item: self.collectionView.numberOfItems(inSection: 0) - 1, section: 0)
            self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        }
    }

    
    func generateUniqueID() -> String {
        var id = ""
        var CheckFolderID = Bool()
        repeat {
            let randomID = String(format: "%04d", arc4random_uniform(10000))
            id = randomID
            CheckFolderID = folderViewViewModel.checkFolderID(folderID: id)
        } while !CheckFolderID
        return id
    }
    
    
    func createDirectory(withName folderName: String) {
        let fileManager = Foundation.FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Unable to access document directory.")
            return
        }
        
        let directoryURL = documentsPath.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            collectionView.reloadData()
            print("Directory created successfully: \(directoryURL.path)")
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }


    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let folders = folderViewViewModel.fetchSavedFolder()
        return folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderPreViewCollectionViewCell", for: indexPath) as! FolderPreViewCollectionViewCell
        let folders = folderViewViewModel.fetchSavedFolder()
            
            guard indexPath.row < folders.count else {
                return cell
            }
            
            let folder = folders[indexPath.row]
            
            guard let folderName = folder.foldername else {
                return cell
            }
        if let searchText = searchController?.searchBar.text, !searchText.isEmpty {
            let attributedString = NSMutableAttributedString(string: folderName)
            let range = (folderName as NSString).range(of: searchText, options: .caseInsensitive)
            
            if range.location != NSNotFound {
                attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.length))
                cell.nameTextFIield.attributedText = attributedString
            } else {
                cell.nameTextFIield.text = folderName
            }
        } else {
            cell.nameTextFIield.text = folderName
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(folderTapped(_:)))
           cell.superView.addGestureRecognizer(tapGesture)
        let clickedFolderID = folder.foldertime
        print("Clicked Folder ID: \(String(describing: clickedFolderID))")
        cell.folderID = clickedFolderID
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    @objc func folderTapped(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: tapLocation) {
            let folders = folderViewViewModel.fetchSavedFolder()
            guard indexPath.row < folders.count else {
                return
            }
            let clickedFolder = folders[indexPath.row]
            let clickedFolderID = clickedFolder.foldertime
            
            let filePreViewVC = FilePreViewViewController.instantiateFromStoryboard()
            filePreViewVC.getFolderID = clickedFolderID ?? ""
            navigationItem.title = ""
            filePreViewVC.folderName = clickedFolder.foldername ?? ""
            self.navigationController?.pushViewController(filePreViewVC, animated: true)
        }
    }


    }


extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: newSize))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        return newImage
    }
}

extension ViewController: PssingTextFieldName {
    func passingTextFieldName(folderName: String, folderID: String) {
        folderViewViewModel.saveFolderCoreData(folderName: folderName, folderID: folderID)
        collectionView.reloadData()
    }
    
}

extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
}
