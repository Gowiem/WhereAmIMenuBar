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
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "menuIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = mainMenu
    }
    
    @IBAction func updateLocationClicked(_ sender: Any) {
        let whereAmI = WhereAmI()
        whereAmI.updateLocation()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

}
