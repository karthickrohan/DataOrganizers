//
//  FolderData+CoreDataProperties.swift
//  DataOrganizer
//
//  Created by VC on 03/04/24.
//
//

import Foundation
import CoreData


extension FolderData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FolderData> {
        return NSFetchRequest<FolderData>(entityName: "FolderData")
    }

    @NSManaged public var foldername: String?
    @NSManaged public var folderdate: Date?
    @NSManaged public var foldertime: String?

}

extension FolderData : Identifiable {

}
