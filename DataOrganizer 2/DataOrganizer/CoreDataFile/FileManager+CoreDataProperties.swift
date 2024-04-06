//
//  FileManager+CoreDataProperties.swift
//  DataOrganizer
//
//  Created by VC on 01/04/24.
//
//

import Foundation
import CoreData


extension FileManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileManager> {
        return NSFetchRequest<FileManager>(entityName: "FileManager")
    }

    @NSManaged public var savedimage: NSData?
    @NSManaged public var folderaID: String?
    @NSManaged public var imagename: String?
    @NSManaged public var imagedate: Date?
    @NSManaged public var imagetime: String?
    @NSManaged public var checkname: String?
    @NSManaged public var filename: String?
    @NSManaged public var filetype: String?
    @NSManaged public var filedata: NSData?
    @NSManaged public var url: String?
    @NSManaged public var favouritecolour: NSData?
    @NSManaged public var isfavourite: Bool
    @NSManaged public var fileuniqueid: String?
    @NSManaged public var addfavouritecolour: NSData?
    @NSManaged public var selectedindex: Int16

    

}

extension FileManager : Identifiable {

}
