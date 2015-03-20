//
//  StatusMenuController.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 3/19/15.
//  Copyright (c) 2015 Etsy. All rights reserved.
//

import Foundation
import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
    let weatherAPI = WeatherAPI()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true) // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        updateWeather()
    }

    func updateWeather() {
        weatherAPI.fetchWeather("Seattle, WA") { weather in
            if let weatherMenuItem = self.statusMenu.itemWithTitle("Weather") {
                weatherMenuItem.title = weather.description
            }
        }
    }
    
    @IBAction func updateClicked(sender: NSMenuItem) {
        updateWeather()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}