//
//  AppDelegate.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import SVProgressHUD

var arrCountrys = [[Country]()]

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var arrJSON: JSON!
    let frontViewController = FrontViewController(nibName: "FrontViewController", bundle: nil)

    func getDataJsonFromLink() {
        
        if Reachability.isConnectedToNetwork() == true {
            SVProgressHUD.showWithStatus("Please wait!")
            
            Alamofire.request(.GET, "https://restcountries.eu/rest/v1/all").responseJSON { response in
                switch response.result {
                case .Success:
                    
                    if let value = response.result.value {
                        self.arrJSON = JSON(value)
                    }
                    self.parseJson()
                    
                case .Failure(let error):
                    print(error.description)
                }
            }
        }
        
    }
    
    func parseJson() {
        
        var arrCountry0 = [Country]()
        var arrCountry1 = [Country]()
        var arrCountry2 = [Country]()
        var arrCountry3 = [Country]()
        var arrCountry4 = [Country]()
        
        for i in 0..<arrJSON.count {
            var dict = arrJSON[i]
            
            let country = Country()
            country.name = dict["name"].stringValue
            country.alpha2Code = dict["alpha2Code"].stringValue.lowercaseString
            country.population = dict["population"].stringValue
            country.area = dict["area"].stringValue
            country.region = dict["region"].stringValue
            
            switch country.region {
            case "Africa":
                arrCountry0.append(country)
            case "Asia":
                arrCountry1.append(country)
            case "Europe":
                arrCountry2.append(country)
            case "Oceania":
                arrCountry3.append(country)
            case "Americas":
                arrCountry4.append(country)
            
            default:
                arrCountry0.append(country)
            }
        }
        
        arrCountrys[0] = arrCountry0
        arrCountrys.append(arrCountry1)
        arrCountrys.append(arrCountry2)
        arrCountrys.append(arrCountry3)
        arrCountrys.append(arrCountry4)
        
        print("parse json done !, arrCountrys: \(arrCountrys.count)")
        
        SVProgressHUD.showSuccessWithStatus("Complete")
        SVProgressHUD.dismissWithDelay(0.5)
        frontViewController.tableView.reloadData()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        
        getDataJsonFromLink()
        
        let rearViewController = RearViewController(nibName: "RearViewController", bundle: nil)
        
        let frontNavigationController = UINavigationController.init(rootViewController: frontViewController)
        let rearNavigationController = UINavigationController.init(rootViewController: rearViewController)
        
        let revealController = SWRevealViewController.init(rearViewController: rearNavigationController, frontViewController: frontNavigationController)
        
        self.window?.rootViewController = revealController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.tuanvi.CountryInfo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("CountryInfo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

