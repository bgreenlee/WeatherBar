//
//  WeatherAPI.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 10/11/15.
//  Copyright © 2015 Etsy. All rights reserved.
//

import Foundation

struct Weather: CustomStringConvertible {
    var city: String
    var currentTemp: Float
    var conditions: String
    var icon: String
    
    var description: String {
        return "\(city): \(currentTemp)F and \(conditions)"
    }
}

class WeatherAPI {
    let API_KEY = "your-api-key-here"
    let BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(query: String, success: (Weather) -> Void) {
        let session = NSURLSession.sharedSession()
        // url-escape the query string we're passed
        let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: "\(BASE_URL)?APPID=\(API_KEY)&units=imperial&q=\(escapedQuery!)")
        let task = session.dataTaskWithURL(url!) { data, response, error in
            if let responseError = error {
                NSLog("error: %s", responseError)
            } else if let weather = self.weatherFromJSONData(data!) {
                success(weather)
            }
        }
        task.resume()
    }
    
    func weatherFromJSONData(data: NSData) -> Weather? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var mainDict = json["main"] as! JSONDict
        var weatherList = json["weather"] as! [JSONDict]
        var weatherDict = weatherList[0]
        
        let weather = Weather(
            city: json["name"] as! String,
            currentTemp: mainDict["temp"] as! Float,
            conditions: weatherDict["main"] as! String,
            icon: weatherDict["icon"] as! String
        )
        
        return weather
    }
}