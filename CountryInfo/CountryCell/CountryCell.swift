//
//  CountryCell.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import CoreData

class CountryCell: UITableViewCell {
    
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var population: UILabel!
    @IBOutlet weak var area: UILabel!
    
    func configureCell(_ country: NSManagedObject) {
        self.name.text = country.value(forKey: "name") as? String
        self.population.text = country.value(forKey: "population") as? String
        let areaString = country.value(forKey: "area") as! String
        self.area.text = "\(areaString) \u{33A2}"
        
        self.name.textColor = BUTTONCOLOR
        self.population.textColor = BUTTONCOLOR
        self.area.textColor = BUTTONCOLOR
        
        let urlString = country.value(forKey: "flagUrl") as! String
        let url = URL(string: urlString)!

        print(url)
        self.flagImg.kf_setImage(with: url)
    }
    
}
