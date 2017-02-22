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
    
    var appManager:AppManager
    
    override init() {
        appManager = AppManager()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("applicationDidFinishLaunching")
        appManager.start()
        
//        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
//                                                              selector:@selector(wakeFromSleep:)
//                                                                   name:NSWorkspaceDidWakeNotification
//                                                                 object:nil];
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        NSLog("applicationWillBecomeActive")
    }
    
}
