//
//  DataBaseHandler.swift
//  DataOrganizer
//
//  Created by VC on 01/04/24.
//

import Foundation
import CoreData
import UIKit

class DataBaseHandler {
    
    var image: UIImage? = nil
    
    static let shared = DataBaseHandler()
        
    private init() {}
    
    
    func fetchInitialData(folderID: String) -> [FileManager] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "folderaID == %@", folderID)
            
            let fetchedData = try context.fetch(fetchRequest)
            return fetchedData
        } catch {
            print("Error fetching initial data: \(error.localizedDescription)")
            return []
        }
    }

    
    func saveImageToCoreData(imageData: Data,folderID: String,itemID: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let photoObject = NSEntityDescription.insertNewObject(forEntityName: "FileManager", into: context) as! FileManager
        let imageDataAsNSData = NSData(data: imageData)
        photoObject.savedimage = imageDataAsNSData
        photoObject.folderaID = folderID
        photoObject.filetype = "image"
        photoObject.fileuniqueid = itemID
        photoObject.imagedate = Date()
        
        do {
            try context.save()
            print("Image saved to Core Data")
        } catch let error as NSError {
            print("Failed to save image to Core Data: \(error.localizedDescription)")
        }
    }


    
    func saveFile(at fileURL: URL, folderID: String,fileID: String) {
        let appDee = UIApplication.shared.delegate as! AppDelegate
        let context = appDee.persistentContainer.viewContext
        
        do {
            let data = try Data(contentsOf: fileURL)
            let fileObject = NSEntityDescription.insertNewObject(forEntityName: "FileManager", into: context) as! FileManager
            fileObject.filedata = data as NSData
            fileObject.filename = fileURL.lastPathComponent
            fileObject.filetype = "public.item"
            fileObject.imagetime = fileURL.absoluteString
            fileObject.imagedate = Date()
            fileObject.folderaID = folderID
            fileObject.fileuniqueid = fileID
            
            try context.save()
            print("File saved successfully")
        } catch {
            print("Error occurred while saving file: \(error)")
        }
    }
    
    func retrieveFiles(index: Int, folderID: String) -> (Data, String)? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folderaID == %@", folderID)
        
        do {
            let results = try context.fetch(fetchRequest)
            if index < results.count {
                let fileData = results[index].filedata! as Data
                let fileName = results[index].filename ?? "Unknown File"
                return (fileData, fileName)
            } else {
                print("No file found at index \(index)")
                return nil
            }
        } catch {
            print("Error fetching files: \(error.localizedDescription)")
            return nil
        }
    }

        
    func saveFolder(withName folderName: String, folderID: String) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
         
            let folder = NSEntityDescription.insertNewObject(forEntityName: "FolderData", into: context) as! FolderData
  
            folder.foldername = folderName
            folder.foldertime = folderID
            folder.folderdate = Date()
            do {
                try context.save()
                print("Folder created and saved to Core Data")
            } catch {
                print("Error saving folder to Core Data: \(error.localizedDescription)")
            }
        }
        
        func fetchFolders() -> [FolderData]? {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                let fetchRequest: NSFetchRequest<FolderData> = FolderData.fetchRequest()
                let folders = try context.fetch(fetchRequest)
                return folders
            } catch {
                print("Error fetching folders from Core Data: \(error.localizedDescription)")
                return nil
            }
        }
    
    func isUniqueID(id: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FolderData")
        fetchRequest.predicate = NSPredicate(format: "foldertime == %@", id)
        
        do {
            let fetchedFolders = try context.fetch(fetchRequest)
            
            return fetchedFolders.isEmpty
        } catch {
            print("Error fetching folders: \(error)")
            return false
        }
    }
    
    func isUniqueFileID(id: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileManager")
        fetchRequest.predicate = NSPredicate(format: "fileuniqueid == %@", id)
        
        do {
            let fetchedFolders = try context.fetch(fetchRequest)
            
            return fetchedFolders.isEmpty
        } catch {
            print("Error fetching folders: \(error)")
            return false
        }
    }
    
    func saveFavouriteDetailsImageData(itemID: String, color: Data, isFavorite: Bool, imageData: Data, selectedIndex: Int, fileName: String, folderID: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "fileuniqueid == %@", itemID)
            let fetchedResults = try context.fetch(fetchRequest)
            if let existingFile = fetchedResults.first {
                let favouriteColour = NSData(data: color)
                let imageDataAsNSData = NSData(data: imageData)
                
                existingFile.savedimage = imageDataAsNSData
                existingFile.filename = fileName
                existingFile.folderaID = folderID
                existingFile.selectedindex = Int16(selectedIndex)
                existingFile.addfavouritecolour = favouriteColour
                existingFile.isfavourite = isFavorite
                existingFile.imagedate = Date()
                
                try context.save()
            } else {
                let newFile = NSEntityDescription.insertNewObject(forEntityName: "FileManager", into: context) as! FileManager
                
                let favouriteColour = NSData(data: color)
                let imageDataAsNSData = NSData(data: imageData)
                
                newFile.savedimage = imageDataAsNSData
                newFile.fileuniqueid = itemID
                newFile.filename = fileName
                newFile.folderaID = folderID
                newFile.selectedindex = Int16(selectedIndex)
                 newFile.addfavouritecolour = favouriteColour
                newFile.isfavourite = isFavorite
                newFile.imagedate = Date()
                
                try context.save()
            }
        } catch {
            print("Failed to update image in Core Data: \(error.localizedDescription)")
        }
    }

    func saveFavouriteDetailsFileData(itemID: String, color: Data, isFavorite: Bool, selectedIndex: Int, fileName: String, folderID: String, fileData: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "fileuniqueid == %@", itemID)
            let fetchedResults = try context.fetch(fetchRequest)
            
            if let existingFile = fetchedResults.first {
                let favouriteColour = NSData(data: color)
                guard let fileURL = URL(string: fileData) else { return }
                let fileDatas = try Data(contentsOf: fileURL)
                
                existingFile.filename = fileName
                existingFile.filedata = fileDatas as NSData
                existingFile.folderaID = folderID
                existingFile.imagetime = fileData
                existingFile.selectedindex = Int16(selectedIndex)
                existingFile.addfavouritecolour = favouriteColour
                existingFile.isfavourite = isFavorite
                existingFile.imagedate = Date()
                
                try context.save()
            } else {
                let newFile = NSEntityDescription.insertNewObject(forEntityName: "FileManager", into: context) as! FileManager
                
                let favouriteColour = NSData(data: color)
                guard let fileURL = URL(string: fileData) else { return }
                let fileDatas = try Data(contentsOf: fileURL)
                
                newFile.fileuniqueid = itemID
                newFile.filename = fileName
                newFile.filedata = fileDatas as NSData
                newFile.folderaID = folderID
                newFile.imagetime = fileData
                newFile.selectedindex = Int16(selectedIndex)
                newFile.addfavouritecolour = favouriteColour
                newFile.isfavourite = isFavorite
                newFile.imagedate = Date()
                
                try context.save()
            }
        } catch {
            print("Failed to update file in Core Data: \(error.localizedDescription)")
        }
    }


    func fetchFileUniqueIDsFromDB(selectedindex: Int) -> [String] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "selectedindex == %d", selectedindex)
            let fetchedData = try context.fetch(fetchRequest)
            let fileUniqueIDs = fetchedData.compactMap { $0.fileuniqueid }
            return fileUniqueIDs
        } catch {
            print("Error fetching initial data: \(error.localizedDescription)")
            return []
        }
    }


    func fetchFiles(uniqueID: String) -> [FileManager] {

        let moc : NSManagedObjectContext
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fileuniqueid == %@",uniqueID)
        do {
            let fileManagers = try context.fetch(fetchRequest)
            print("fileManagersfileManagers:\(fileManagers)")
            return fileManagers
        } catch {
            print("Error fetching files: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllDataFromDB() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<FileManager> = FileManager.fetchRequest()
        
        do {
            let fetchedData = try context.fetch(fetchRequest)
            
            for data in fetchedData {
                context.delete(data)
            }
            try context.save()
            print("All data deleted from Core Data")
        } catch let error as NSError {
            print("Failed to delete all data from Core Data: \(error.localizedDescription)")
        }
    }
    
    func deleteFolderDataFromDB() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<FolderData> = FolderData.fetchRequest()
        
        do {
            let fetchedData = try context.fetch(fetchRequest)
            
            for data in fetchedData {
                context.delete(data)
            }
            
            try context.save()
            print("All data deleted from Core Data")
        } catch let error as NSError {
            print("Failed to delete all data from Core Data: \(error.localizedDescription)")
        }
    }
    
    func updateFolderName(folderID: String, newName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FolderData")
        fetchRequest.predicate = NSPredicate(format: "foldertime == %@", folderID)
        
        do {
            let folders = try managedContext.fetch(fetchRequest)
            if let folder = folders.first as? NSManagedObject {
                folder.setValue(newName, forKey: "foldername")
                try managedContext.save()
                print("Folder name updated successfully")
            }
        } catch let error as NSError {
            print("Error updating folder name: \(error.localizedDescription)")
        }
    }



}


