//
//  FavouritesFileViewViewController.swift
//  DataOrganizer
//
//  Created by VC on 05/04/24.
//

import Foundation
import UIKit

class FavouritesFileViewViewController: UIViewController,StoryboardInstantiable, UISearchControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var superView: UIView!
    @IBOutlet var tableView: UITableView!
    
    static var storyboardName: String = "FavouritesFileViewViewController"
        private var searchController: UISearchController?
        
        var allColors: [UIColor] = [
            UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.orange,
            UIColor.purple, UIColor.cyan, UIColor.magenta, UIColor.brown, UIColor.gray
        ]
        let colorNames = ["Red", "Blue", "Green", "Yellow", "Orange", "Purple", "Cyan", "Magenta", "Brown", "Gray"]
        
        
        var filteredColors: [UIColor] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            searchController?.delegate = self
            setUpTableView()
            setNavigationBar()
            setupSearchOnNavigationbar()
            setNavigationButton()
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            tableView.separatorColor = UIColor.clear
            filteredColors = allColors
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
            tableView.register(UINib(nibName: FavouritesFileviewTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: FavouritesFileviewTableViewCell.cellIdentifier)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            filterColors(searchText: searchText)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = nil
            filteredColors = allColors
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
        
        func filterColors(searchText: String) {
            if searchText.isEmpty {
                filteredColors = allColors
            } else {
                filteredColors = allColors.filter { color in
                    let colorName = colorNames[allColors.firstIndex(of: color) ?? 0]
                    return colorName.localizedCaseInsensitiveContains(searchText)
                }
            }
            tableView.reloadData()
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
            self.title = "FavouriteFolders"
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        }
        
        func setNavigationButton() {
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
    }
    extension FavouritesFileViewViewController: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredColors.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavouritesFileviewTableViewCell", for: indexPath) as? FavouritesFileviewTableViewCell else {
                return UITableViewCell()
            }
            
            guard indexPath.row < filteredColors.count else {
                return cell
            }
            
            let color = filteredColors[indexPath.row]
            cell.colourView.backgroundColor = color
            let colorName = colorNames[allColors.firstIndex(of: color) ?? 0]
            cell.coloursNameLabel.text = colorName
            
            return cell
        }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedRow = indexPath.row
            pressedFavoriteFolder(indexPath: indexPath,selectedIndex: selectedRow)
        }
        
        @objc func pressedFavoriteFolder(indexPath: IndexPath,selectedIndex: Int) {
            let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.purple, UIColor.cyan, UIColor.magenta, UIColor.brown, UIColor.gray]
            let selectedColor = colors[indexPath.row]
            let favouriteController = FavouriteFilePreViewController.instantiateFromStoryboard()
            favouriteController.fileColour = selectedColor
            favouriteController.selectedindex = selectedIndex
            self.navigationController?.pushViewController(favouriteController, animated: true)
            
        }
        
    }

    extension UIColor {
        var hexString: String {
            guard let components = self.cgColor.components, components.count >= 3 else { return "" }
            
            let red = components[0]
            let green = components[1]
            let blue = components[2]
            
            return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
        }
    }
