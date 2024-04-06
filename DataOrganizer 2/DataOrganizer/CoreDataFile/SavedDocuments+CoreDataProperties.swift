//
//  SavedDocuments+CoreDataProperties.swift
//  DataOrganizer
//
//  Created by VC on 03/04/24.
//
//

import Foundation
import CoreData


extension SavedDocuments {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedDocuments> {
        return NSFetchRequest<SavedDocuments>(entityName: "SavedDocuments")
    }
    @NSManaged public var filetype: String?
    @NSManaged public var filename: String?
    @NSManaged public var filedata: NSData?

}

extension SavedDocuments : Identifiable {

}
