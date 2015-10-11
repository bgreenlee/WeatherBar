//
//  WeatherAPI.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 3/19/15.
//  Copyright (c) 2015 Etsy. All rights reserved.
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
    let BASE_URL = "http://api.openweathermap.org/data/2.5/weather?units=imperial&q="

    func fetchWeather(query: String, success: (Weather) -> Void) {
        let session = NSURLSession.sharedSession()
        let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: BASE_URL + escapedQuery!)
        let task = session.dataTaskWithURL(url!) { data, response, error in
            if let weather = self.weatherFromJSONData(data!) {
                success(weather)
            }
        }
        task!.resume()
    }

    func weatherFromJSONData(data: NSData) throws -> Weather? {
        typealias JSONDict = [String:AnyObject]

        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! JSONDict
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
        } catch let error as NSError {
            print("A JSON parsing error occurred: \(error)")
        }
        throw
    }
}
