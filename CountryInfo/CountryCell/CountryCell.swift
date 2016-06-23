//
//  CountryCell.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import CoreData

class CountryCell: UITableViewCell {
    
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var population: UILabel!
    @IBOutlet weak var area: UILabel!
    
    func configureCell(country: NSManagedObject) {
        self.name.text = country.valueForKey("name") as? String
        self.population.text = country.valueForKey("population") as? String
        let areaString = country.valueForKey("area") as! String
        self.area.text = "\(areaString) \u{33A2}"
        
        let urlString = country.valueForKey("flagUrl") as! String
        let url = NSURL(string: urlString)!

        print(url)
        self.flagImg.kf_setImageWithURL(url, placeholderImage: nil)
    }
    
}
