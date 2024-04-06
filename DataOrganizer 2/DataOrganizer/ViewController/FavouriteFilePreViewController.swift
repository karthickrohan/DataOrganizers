//
//  FavouriteFilePreViewController.swift
//  DataOrganizer
//
//  Created by VC on 05/04/24.
//

import UIKit
import CoreData

class FavouriteFilePreViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate,StoryboardInstantiable, UIGestureRecognizerDelegate {
    
    @IBOutlet var superView: UIView!
    @IBOutlet var tabelView: UITableView!
    
    
    static var storyboardName: String = "FavouriteFilePreViewController"
    private var searchController: UISearchController?
    var favouriteFilePreViewViewModel = FavouriteFilePreViewViewModel()
    var initialFetchResult = [FileManager]()
    var fileUniqueID = [String]()
    var fileColour : UIColor?
    var finalColour : Data?
    var selectedindex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.dataSource = self
        tabelView.delegate = self
        searchController?.delegate = self
        setUpTableView()
        setNavigationBar()
        setupSearchOnNavigationbar()
        setNavigationLeftBarButton()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabelView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tabelView.separatorColor = UIColor.clear
        loadDataFromDB()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    
    func loadDataFromDB() {
        fileUniqueID = favouriteFilePreViewViewModel.fetchFavouritesIteamIDFromDB(selectedindex: selectedindex ?? 0)
        initialFetchResult = []
        
        for i in fileUniqueID {
            let fetchedFiles = favouriteFilePreViewViewModel.fetchFavouritesFiles(itemID: i)
            let newFiles = fetchedFiles.filter { newFile in
                !initialFetchResult.contains { existingFile in
                    newFile.fileuniqueid == existingFile.fileuniqueid
                }
            }
            initialFetchResult.append(contentsOf: newFiles)
        }
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
    
    func setUpTableView() {
        tabelView.register(UINib(nibName: FavouritesFilePreViewTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: FavouritesFilePreViewTableViewCell.cellIdentifier)
    }
    
    func setupSearchOnNavigationbar() {
        if self.navigationItem.searchController == nil {
            
            let searchController = UISearchController(searchResultsController: nil)
            self.navigationItem.searchController = searchController
            
            searchController.delegate = self
            searchController.searchBar.delegate = self
            searchController.searchBar.showsBookmarkButton = false
            
        }
        self.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func setNavigationBar() {
        self.title = "FavouritesFile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
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
    
    
    func setNavigationButton() {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let chevButton = UIButton(type: UIButton.ButtonType.custom)
        chevButton.setImage(UIImage(named: "ios Back (1)"), for: .normal)
        chevButton.frame = CGRect(x:0, y: 0, width: 24, height: 40)
        chevButton.addTarget(self, action: #selector(pressedBackButton), for: .touchUpInside)
        let nameButton = UIButton(type: UIButton.ButtonType.custom)
        nameButton.frame = CGRect(x:20, y: 0, width: 50, height: 40)
        nameButton.setTitle("Back", for: .normal)
        nameButton.addTarget(self, action: #selector(pressedBackButton), for: .touchUpInside)
        nameButton.setTitleColor(UIColor.blue, for: .normal)
        backView.addSubview(chevButton)
        backView.addSubview(nameButton)
        let customView = UIBarButtonItem(customView: backView)
        navigationItem.leftBarButtonItems = [customView]
    }
    
    @objc func pressedBackButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension FavouriteFilePreViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Set(initialFetchResult.map { $0.fileuniqueid }).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavouritesFilePreViewTableViewCell", for: indexPath) as? FavouritesFilePreViewTableViewCell else {
            return UITableViewCell()
        }
        
        guard indexPath.row < initialFetchResult.count else {
            return UITableViewCell()
        }
        
        let item = initialFetchResult[indexPath.row]
        cell.configure(image: UIImage(), date: item.imagedate ?? Date(), fileType: item.filetype ?? "")
        
        if let imageData = item.savedimage as Data?, let image = UIImage(data: imageData) {
            cell.imageIcon?.image = image
            cell.nameLabel?.text = item.imagename
            if  item.imagename == nil {
                cell.nameLabel?.text = "img"
            }
        }
        
        if let fileData = item.filedata as Data?, let fileType = item.filetype {
            cell.nameLabel?.text = item.filename
            if  item.filename == nil {
                cell.nameLabel?.text =  item.filetype
            }
            cell.getFileImage(fileType: fileType, date: item.imagedate ?? Date())
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separateView.isHidden = true
        } else {
            cell.separateView.isHidden = false
        }
        
        return cell
    }
    
    
}

extension UIColor {
    func toData() -> Data? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let colorDict: [String: CGFloat] = ["red": red, "green": green, "blue": blue, "alpha": alpha]
        
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: colorDict, requiringSecureCoding: false)
            return colorData
        } catch {
            print("Error converting UIColor to Data: \(error.localizedDescription)")
            return nil
        }
    }
}

