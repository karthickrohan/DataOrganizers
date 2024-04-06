//
//  Files+CoreDataProperties.swift
//  DataOrganizer
//
//  Created by VC on 03/04/24.
//
//

import Foundation
import CoreData


extension FileData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileData> {
        return NSFetchRequest<FileData>(entityName: "FileData")
    }

    @NSManaged public var filetype: Data?
    @NSManaged public var filename: Data?
    @NSManaged public var filedata: Data?

}

extension FileData : Identifiable {

}
