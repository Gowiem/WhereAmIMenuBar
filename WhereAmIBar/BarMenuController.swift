//
//  BarMenuController.swift
//  WhereAmIBar
//
//  Created by Matt Gowie on 2/18/17.
//  Copyright © 2017 Masterpoint. All rights reserved.
//

import Cocoa

class BarMenuController: NSObject {
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var appManager: AppManager!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        NSLog("awakeFromNib!")
        let icon = NSImage(named: "menuIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = mainMenu
    }
    
    func updateMenu(latestUpdateInfo: [String: Any?]) {
        NSLog("Adding menu items!")
        
        let timestamp = latestUpdateInfo["timestamp"] as! String
        let dateString = buildDateString(timestamp)
        mainMenu.insertItem(withTitle: "Last Update: \(dateString)", action: nil, keyEquivalent: "", at: 0)
        
        let locationString = buildLocationString(latestUpdateInfo)
        mainMenu.insertItem(withTitle: "Location: \(locationString)", action: nil, keyEquivalent: "", at: 1)
        
        mainMenu.insertItem(NSMenuItem.separator(), at: 2)
    }
    
    private func buildDateString(_ timestamp: String) -> String {
        let updateTime = NSDate(timeIntervalSince1970: Double(timestamp)!)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        
        return dayTimePeriodFormatter.string(from: updateTime as Date)
    }
    
    private func buildLocationString(_ info: [String: Any]) -> String {
        let city = info["city"] as! String
        let country = info["country_long"] as! String
        
        return "\(city), \(country)"
    }
    
    @IBAction func updateLocationClicked(_ sender: Any) {
        appManager.manualUpdate()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

}
