//
//  FilePreViewViewModel.swift
//  DataOrganizer
//
//  Created by VC on 03/04/24.
//

import Foundation
import CoreData


class FilePreViewViewModel {
    let dataHandler = DataBaseHandler.shared
    
    func savingImageCoreData(imageData: NSData, folderID: String,itemID: String) {
        return dataHandler.saveImageToCoreData(imageData: imageData as Data, folderID: folderID, itemID: itemID)
    }
    
    
    func saveFile(fileURL: URL, folderID: String,fileID: String) {
        return dataHandler.saveFile(at: fileURL, folderID: folderID,fileID: fileID)
    }
  
    
    func getAllData(folderID: String) -> [FileManager] {
        return dataHandler.fetchInitialData(folderID: folderID)
    }
    
    func isUniqueFileID(fileID: String) -> Bool {
        return dataHandler.isUniqueFileID(id: fileID)
    }
    
    func saveFavouriteDetailsData(itemID: String, color: NSData?, isFavorite: Bool,imageData: NSData,selectedIndex: Int,fileName: String,folderid: String) {
        return dataHandler.saveFavouriteDetailsImageData(itemID: itemID, color: color! as Data, isFavorite: isFavorite,imageData: imageData as Data,selectedIndex: selectedIndex,fileName: fileName,folderID: folderid)
    }
    
    func saveFilesData(itemID: String, color: NSData?, isFavorite: Bool,selectedIndex: Int,fileName: String,folderID: String,fileData: String) {
        return dataHandler.saveFavouriteDetailsFileData(itemID: itemID, color: color! as Data, isFavorite: isFavorite, selectedIndex: selectedIndex, fileName: fileName, folderID: folderID, fileData: fileData)
        
    }
    
    
}
