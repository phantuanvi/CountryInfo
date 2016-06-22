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

class CountryCell: UITableViewCell {
    
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var population: UILabel!
    @IBOutlet weak var area: UILabel!
    
    func configureCell(country: Country) {
        self.name.text = country.name
        self.population.text = country.population
        self.area.text = country.area
        
        let url = NSURL(string:"https://raw.githubusercontent.com/hjnilsson/country-flags/master/png250px/\(country.alpha2Code).png")!

        print(url)
        self.flagImg.kf_setImageWithURL(url, placeholderImage: nil)
    }
    
}
