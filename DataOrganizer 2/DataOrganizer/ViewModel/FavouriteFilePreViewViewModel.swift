//
//  FavouriteFilePreViewViewModel.swift
//  DataOrganizer
//
//  Created by VC on 05/04/24.
//

import Foundation
import UIKit

class FavouriteFilePreViewViewModel {
    
    
    let dataHandler = DataBaseHandler.shared
    
    
    func fetchFavouritesIteamIDFromDB(selectedindex: Int) -> [String] {
        return dataHandler.fetchFileUniqueIDsFromDB(selectedindex: selectedindex)
       
    }
    
    func fetchFavouritesFiles(itemID: String) -> [FileManager]{
        return dataHandler.fetchFiles(uniqueID: itemID)
    }
    
}
