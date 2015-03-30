//
//  PreferencesWindow.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 3/20/15.
//  Copyright (c) 2015 Etsy. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var cityTextField: NSTextField!
    var delegate: PreferencesWindowDelegate?
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let city = defaults.stringForKey("city") ?? DEFAULT_CITY
        cityTextField.stringValue = city

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func windowWillClose(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(cityTextField.stringValue, forKey: "city")
        delegate?.preferencesDidUpdate()
    }
    
}
