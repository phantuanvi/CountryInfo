//
//  CountryCell.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import Alamofire

class CountryCell: UITableViewCell {
    
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var population: UILabel!
    
    static var imageCache = NSCache()
    
    func configureCell(country: Country, img: UIImage?) {
        self.name.text = country.name
        self.population.text = country.population
        //        if let url = NSURL(string: country.flag), let data = NSData(contentsOfURL: url) {
        //            cell.flag.image = UIImage(data: data)
        //        }
        
        Alamofire.request(.GET, country.flagUrl).validate(contentType: ["*/flags/*"]).response { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
            
            if error == nil {
                let img = UIImage(data: data!)!
                self.flag.image = img
                FrontViewController.imageCache.setObject(img, forKey: country.flagUrl)
            } else {
                print(error.debugDescription)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
