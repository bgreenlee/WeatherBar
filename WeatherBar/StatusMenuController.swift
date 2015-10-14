//
//  StatusMenuController.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 10/11/15.
//  Copyright © 2015 Etsy. All rights reserved.
//

import Cocoa

let DEFAULT_CITY = "Seattle, WA"

class StatusMenuController: NSObject, PreferencesWindowDelegate {    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var weatherView: WeatherView!

    var weatherMenuItem: NSMenuItem!
    var preferencesWindow: PreferencesWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let weatherAPI = WeatherAPI()
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        let icon = NSImage(named: "statusIcon")
        icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        weatherMenuItem = statusMenu.itemWithTitle("Weather")
        weatherMenuItem.view = weatherView
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        updateWeather()
    }
    
    func updateWeather() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let city = defaults.stringForKey("city") ?? DEFAULT_CITY
        weatherAPI.fetchWeather(city) { weather in
            self.weatherView.update(weather)
        }
    }
    
    @IBAction func updateClicked(sender: NSMenuItem) {
        updateWeather()
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func preferencesDidUpdate() {
        updateWeather()
    }
}
