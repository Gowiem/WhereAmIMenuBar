 //
//  AppManager.swift
//  WhereAmIBar
//
//  Created by Matt Gowie on 2/22/17.
//  Copyright © 2017 Masterpoint. All rights reserved.
//

import Foundation

class AppManager: NSObject {
    
    @IBOutlet weak var barMenuController: BarMenuController!
    var backgroundActivity: NSBackgroundActivityScheduler?
    var whereAmI: WhereAmI
    
    private var _lastUpdateInfo: [String: Any]?
    var lastUpdateInfo: [String: Any]? {
        set {
            _lastUpdateInfo = newValue
            barMenuController.updateMenu(latestUpdateInfo: newValue as! [String : Any?])
        }
        get { return _lastUpdateInfo }
    }
    
    override init() {
        NSLog("AppManager - Init")
        self.whereAmI = WhereAmI()
    }
    
    func manualUpdate() {
        whereAmI.updateLocation().then { _ in
            NSLog("Manual location update finished!")
        }.catch { error in
            NSLog("Failed to update location manually -- error: \(error)")
        }
    }
    
    func start() {
        self.whereAmI.updateLocation().then { locationInfo -> Void in
            NSLog("Finished first location up, scheduling recurring!")
            self.lastUpdateInfo = locationInfo
            self.schedule()
        }.catch { error in
            // Schedule another attempt later
            NSLog("Failed to update location. Error: \(error)")
            self.schedule()
        }
    }
    
    private func schedule() {
        let activity = NSBackgroundActivityScheduler(identifier: "com.masterpoint.WhereAmIBar.updatelocation")
        
        // Set activity to repeat every hour.
        activity.repeats = true
        activity.interval = 60
        
        activity.schedule { (completion: @escaping NSBackgroundActivityScheduler.CompletionHandler) in
            NSLog("Firing reccuring updateLocation")
            let lastIp = self.lastUpdateInfo?["ip"] as! String
            self.whereAmI.updateLocation(previousIp: lastIp).then { locationInfo -> Void in
                NSLog("Scheduled update finished!")
                self.lastUpdateInfo = locationInfo
                completion(NSBackgroundActivityScheduler.Result.finished)
            }.catch { error in
                switch error {
                case WhereAmIError.NoReasonToUpdateCancel:
                    NSLog("No reason to update location since same IP Address")
                default:
                    NSLog("Failed to update location. Error: \(error)")
                }
                completion(NSBackgroundActivityScheduler.Result.finished)
            }
        }
        
        backgroundActivity = activity
    }
}
