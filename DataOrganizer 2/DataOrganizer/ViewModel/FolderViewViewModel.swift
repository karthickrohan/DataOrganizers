//
//  FolderViewViewModel.swift
//  DataOrganizer
//
//  Created by VC on 03/04/24.
//

import Foundation
import CoreData

class FolderViewViewModel {
    
    let dataHandler = DataBaseHandler.shared
    
    
    func saveFolderCoreData(folderName: String,folderID: String?) {
        return dataHandler.saveFolder(withName: folderName, folderID: folderID ?? "")
    }
    
    func fetchSavedFolder() -> [FolderData] {
        guard let folders = dataHandler.fetchFolders() else {
            return []
        }
        return folders
    }
    
    func  checkFolderID(folderID: String) -> Bool {
        return dataHandler.isUniqueID(id: folderID)
    }
    
    func updateFolderName(folderID: String,newName: String) {
        return dataHandler.updateFolderName(folderID: folderID, newName: newName)
    }
}
