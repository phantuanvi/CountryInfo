//
//  Country+CoreDataProperties.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 6/22/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Country {

    @NSManaged var name: String?
    @NSManaged var alpha2Code: String?
    @NSManaged var population: String?
    @NSManaged var area: String?
    @NSManaged var region: String?
    @NSManaged var flagUrl: String?

}
