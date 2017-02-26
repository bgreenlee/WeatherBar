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

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let weatherAPI = WeatherAPI()
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        weatherMenuItem = statusMenu.item(withTitle: "Weather")
        weatherMenuItem.view = weatherView
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        updateWeather()
    }
    
    func updateWeather() {
        let defaults = UserDefaults.standard
        let city = defaults.string(forKey: "city") ?? DEFAULT_CITY
        weatherAPI.fetchWeather(city) { weather in
            self.weatherView.update(weather)
        }
    }
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        updateWeather()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    func preferencesDidUpdate() {
        updateWeather()
    }
}
