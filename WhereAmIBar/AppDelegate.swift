//
//  AppDelegate.swift
//  WhereAmIBar
//
//  Created by Matt Gowie on 2/18/17.
//  Copyright © 2017 Masterpoint. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var appManager: AppManager!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("applicationDidFinishLaunching")
        appManager.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        NSLog("applicationWillBecomeActive")
    }
    
}
