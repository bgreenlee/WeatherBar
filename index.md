---
layout: default
---

# Write a Mac Menu Bar App in Swift

This tutorial will walk you through writing a Mac Menu Bar (aka Status Bar) app, using Swift.

### Create the Project
- Open Xcode
- Create a New Project or File -> New -> Project
- Choose Application -> Cocoa Application under OS X and click Next
- Product Name: WeatherBar, Language Swift, uncheck Use Storyboards
- Next and save somewhere

### Let's Code!

- Click on MainMenu.xib
- Under Objects, delete the default window and menu
- Go to the library, type "menu" and drag out an NSMenu
- Delete all but one item
- rename item to Quit. In Attributes Inspector (⌥⌘4), click on the Key Equivalent field and type ⌘Q
- Open the Assistant Editor (⌥⌘↩)
- ctrl-drag from Menu to code (AppDelegate.swift) and create a statusMenu outlet
- ctrl-drag from the Quit menu item to the code and create a quitClicked action (set type to NSMenuItem)
- in AppDelegate.swift:
    - delete the `window` var
    - under `statusMenu`, add:

~~~ swift
let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
~~~

(The `NSVariableStatusItemLength` (-1) and `NSSquareStatusItemLength` (-2) constants have not been ported over to Swift yet.)
    - in `applicationDidFinishLaunching`, add:

~~~ swift
statusItem.title = "WeatherBar"
statusItem.menu = statusMenu
~~~

- in `quitClicked`:

    NSApplication.sharedApplication().terminate(self)

- run it

## Get rid of the dock icon and menu

- click target, then info
- in properties, add new property (click on the last property and then on the + that appears)
- type "Application is agent (UIElement)" and set the value to YES
- run again

## Create an icon

- Create the icon
    + have two icons, one 18x18 and one 36x36
    + click Images.xcassets, then plus on the bottom of the next panel to the right, and select new image set
    + name the image set "statusIcon" and drag the icons into the 1x and 2x boxes


- in `applicationDidFinishLaunching`:

    let icon = NSImage(named: "statusIcon")
    icon?.setTemplate(true) // best for dark mode
    statusItem.image = icon
    statusItem.menu = statusMenu

- delete the statusItem.title line

- run again

## Reorganize

Before we add more code, we should find a better place to put it. The ApplicationDelegate is really meant to be used only for handling application lifecycle events. We *could* dump all our code in there, but at some point you're going to hate yourself (or the next developer to work on your code will be thinking stabby thoughts).

- File -> New File -> Source -> Swift File -> "StatusMenuController"

~~~ swift
    import Foundation
    import Cocoa

    class StatusMenuController: NSObject {
        @IBOutlet weak var statusMenu: NSMenu!

        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength

        override func awakeFromNib() {
            let icon = NSImage(named: "statusIcon")
            icon?.setTemplate(true) // best for dark mode
            statusItem.image = icon
            statusItem.menu = statusMenu
        }

        @IBAction func quitClicked(sender: NSMenuItem) {
            NSApplication.sharedApplication().terminate(self)
        }
    }
~~~

- Go to MainMenu.xib
- In the Library, type "object", and then drag an Object over to just above your Menu.
- Name the Object "StatusMenuController", select the Identity Inspector (⌥⌘3), and enter "StatusMenuController" in the Class field
- right-click on the StatusMenuController object, and under Outlets, drag the circle next to statusMenu over to your Menu object.
- do that again for the quit-clicked action, going to your Quit menu item
- finally, right-click on the App Delegate object and click the X next to the statusMenu outlet to clear that association.
- Now, when the application is launched and the StatusMenu.xib is instantiated, our StatusMenuController will receive `awakeFromNib`, and we can do what we need to initialize the status menu.
- Delete the code we added to AppDelegate

## Calling the API

The next thing we need is something to manage communication with the weather API

- File -> New File -> Source -> Swift File -> WeatherAPI.swift

~~~ swift
class WeatherAPI {
    let BASE_URL = "http://api.openweathermap.org/data/2.5/weather?units=imperial&q="

    func fetchWeather(query: String) {
        let session = NSURLSession.sharedSession()
        let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: BASE_URL + escapedQuery!)
        let task = session.dataTaskWithURL(url!) { data, response, error in
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) as String
            NSLog(dataString)
        }
        task.resume()
    }
}
~~~

Now we need a way to call this. We could just stick a call in AppDelegate or StatusMenuController#awakeFromNib, but lets be a little less lazy and add a menu item to call it.

- in MainMenu.xib, type "Menu Item" into the library search field (bottom right), and drag a menuItem over to above Quit in your menu
- while we're at it, drag a Separator Menu Item between those two
- Rename the new menu item "Update" (and give it a key equivalent if you want)
- Open the Assistant Editor with StatusMenuController.swift and ctrl-drag from Update over to your code above `quitClicked` and create a new action, `updateClicked`, with the type again as `NSMenuItem`
- we need to instantiate WeatherAPI, so in StatusMenuController at the top, under `let statusItem` add:

~~~ swift
let weatherAPI = WeatherAPI()
~~~

and in `updateClicked`, add:

~~~ swift
weatherAPI.fetchWeather("Seattle")
~~~

- run it, and select Update

- you probably want it to fetch the weather as soon as the app launches. I reorganized my `StatusMenuController` a bit to do this. Here's what it looks like now:

~~~ swift
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
        weatherAPI.fetchWeather("Seattle")
    }

    @IBAction func updateClicked(sender: NSMenuItem) {
        updateWeather()
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
~~~

## Parsing JSON

Parsing JSON is a little awkward in Swift, and people have written libraries, like [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) to make this easier, but our needs our simple and I don't want to complicate things with installing external libraries (although if you do, the two main package managers for Xcode are [Carthage](https://github.com/Carthage/Carthage) and CocoaPODS(http://cocoapods.org/)).

Here's the JSON returned by OpenWeatherMap:

~~~json
{
    "coord": {
        "lon": -122.33,
        "lat": 47.6
    },
    "sys": {
        "type": 1,
        "id": 2923,
        "message": 0.0242,
        "country": "United States of America",
        "sunrise": 1426774374,
        "sunset": 1426818056
    },
    "weather": [{
        "id": 800,
        "main": "Clear",
        "description": "sky is clear",
        "icon": "01d"
    }],
    "base": "cmc stations",
    "main": {
        "temp": 52.41,
        "pressure": 1020,
        "humidity": 76,
        "temp_min": 48.2,
        "temp_max": 57
    },
    "wind": {
        "speed": 7.78,
        "deg": 180
    },
    "clouds": {
        "all": 1
    },
    "dt": 1426790612,
    "id": 5809844,
    "name": "Seattle",
    "cod": 200
}
~~~

There's a lot of information we could use here, but for now let's just take the city name, current temperature, and the weather description. Let's first create a place to put the weather data. In WeatherAPI.swift, add a struct at the top of the file:

~~~ swift
struct Weather {
    var city: String
    var currentTemp: Float
    var conditions: String
}
~~~

Now add a function to parse the incoming JSON data and return a Weather object:

~~~ swift
func weatherFromJSONData(data: NSData) -> Weather? {
    var err: NSError?
    typealias JSONDict = [String:AnyObject]

    if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &err) as? JSONDict {
        var mainDict = json["main"] as JSONDict
        var weatherList = json["weather"] as [JSONDict]
        var weatherDict = weatherList[0]

        var weather = Weather(
            city: json["name"] as String,
            currentTemp: mainDict["temp"] as Float,
            conditions: weatherDict["main"] as String
        )

        return weather
    }
    return nil
}
~~~

We return an Optional(Weather) because it's possible the JSON may fail to parse.

Now, change the `fetchWeather` function to call `weatherFromJSONData`:

~~~ swift
let task = session.dataTaskWithURL(url!) { data, response, error in
    let weather = self.weatherFromJSONData(data)
    NSLog("\(weather)")
}
~~~

If you run it now, you'll see that the logging isn't terribly helpful:

~~~
2015-03-19 14:58:00.758 WeatherBar[49688:1998824] Optional(WeatherBar.Weather)
~~~

To make our Weather struct printable, we need to implement the [Printable](https://developer.apple.com/library/ios/documentation/General/Reference/SwiftStandardLibraryReference/Printable.html) or DebugPrintable protocols. Let's do the former:

~~~ swift
struct Weather: Printable {
    var city: String
    var currentTemp: Float
    var conditions: String

    var description: String {
        return "\(city): \(currentTemp)F and \(conditions)"
    }
}
~~~

If you run it again now you'll see:

~~~
2015-03-19 15:11:49.130 WeatherBar[50731:2009152] Optional(Seattle: 58.87F and Clouds)
~~~

## Getting the Weather into the Controller

Next, let's actually display the weather in our app, as opposed to in the debug console.

First we have the problem of how we get the weather data back into our controller. The weather API call is asynchronous, so we can't just call weatherAPI.fetchWeather() and expect a Weather object in return.

There are two common ways to handle this. The most common pattern in MacOS and iOS programming (at least up until recently), is to use a delegate:

Add the following above `class WeatherAPI`:

~~~ swift
protocol WeatherAPIDelegate {
    func weatherDidUpdate(weather: Weather)
}
~~~

Add the following class variable to WeatherAPI:

~~~ swift
var delegate: WeatherAPIDelegate?
~~~

Add an initializer fuction:

~~~ swift
init(delegate: WeatherAPIDelegate) {
    self.delegate = delegate
}
~~~

And now the data fetch task in `fetchWeather` will look like this:

~~~ swift
let task = session.dataTaskWithURL(url!) { data, response, error in
    if let weather = self.weatherFromJSONData(data) {
        self.delegate?.weatherDidUpdate(weather)
    }
}
~~~

Finally, we implement the `WeatherAPIDelegate` protocol in the controller, with a few changes noted:

~~~ swift
class StatusMenuController: NSObject, WeatherAPIDelegate {
...
  var weatherAPI: WeatherAPI!

  override func awakeFromNib() {
    ...
    weatherAPI = WeatherAPI(delegate: self)
    updateWeather()
  }
  ...
  func weatherDidUpdate(weather: Weather) {
    NSLog(weather.description)
  }
  ...
~~~

However, with the relatively recent introduction of blocks to Objective-C, and Swift's first-class functions, a simpler way is to use callbacks:

~~~ swift
func fetchWeather(query:String, success: (Weather) -> Void) {
    let session = NSURLSession.sharedSession()
    let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let url = NSURL(string: BASE_URL + escapedQuery!)
    let task = session.dataTaskWithURL(url!) { data, response, error in
        if let weather = self.weatherFromJSONData(data) {
            success(weather)
        }
    }
    task.resume()
}
~~~

Here, `success` is a function that takes a Weather object as a parameter and returns `Void` (nothing).

In our controller:

~~~ swift
func updateWeather() {
    weatherAPI.fetchWeather("Seattle, WA") { weather in
        NSLog(weather.description)
    }
}
~~~

## Displaying the Weather

Finally, we'll update our menu to display the weather.

In MainMenu.xib, add a new MenuItem between Update and Quit (and another separator) and rename it "Weather".

![](assets/weather-menu-item.png)

In your controller, in `updateWeather`, replace the `NSLog` with:

~~~ swift
if let weatherMenuItem = self.statusMenu.itemWithTitle("Weather") {
    weatherMenuItem.title = weather.description
}
~~~

Run and voila!

The weather is greyed out because we have no action associated with selecting it. We could have it open a web page to a detailed forecast, but instead next we'll make a nicer display.

## Creating a Weather UIView

Open MainMenu.xib.

Drag a Custom View onto the page.

Drag a Image View into the upper left corner of the view, and in the Image View's Size Inspector, set the width and height to 50.

Add Labels for city and current temperature/conditions (we'll use one label for both temperature and conditions).

Adjust the view size down to about 265 x 90 (you can set that in the Image View's Size Inspector). It should look roughly like this:

![](assets/image-view.png)

New File -> Source -> Cocoa Class, name it WeatherView and make it a subclass of NSView, and save. The file will contain a stub `drawRect` method which you can delete.

Back in MainMenu.xib, click on the View, and in the Identity Inspector, set the class to "WeatherView". Now use the Assistant editor to bring up the xib and class file side-by-side, and then ctrl-drag from the xib to create outlets for each of the elements in the view. WeatherView.swift should look like:

~~~ swift
import Cocoa

class WeatherView: NSView {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var currentConditionsTextField: NSTextField!
}
~~~

Now add a method to WeatherView so we can update it with a Weather object:

~~~ swift
    func update(weather: Weather) {
        cityTextField.stringValue = weather.city
        currentConditionsTextField.stringValue = "\(Int(weather.currentTemp))°F and \(weather.conditions)"
    }
~~~

Now bring up StatusMenuController in the Assistant editor, and ctrl-drag from the Weather View object over to the top of the StatusMenuController class to create a `weatherView` outlet. While we're there, we're going to add a `weatherMenuItem` class var:

~~~ swift
class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var weatherView: WeatherView!
    var weatherMenuItem: NSMenuItem!
    ...
~~~

In StatusMenuController's `awakeFromNib` method, right before the call to `updateWeather`, add:

~~~ swift
// load WeatherView
weatherMenuItem = statusMenu.itemWithTitle("Weather")
weatherMenuItem.view = weatherView
~~~

And now `updateWeather` is even simpler:

~~~ swift
func updateWeather() {
    weatherAPI.fetchWeather("Seattle, WA") { weather in
        self.weatherView.update(weather)
    }
}
~~~

Run it!

## Adding the Weather Image

So, we're obviously missing something in our weather view. Let's update it with the appropriate weather image.

The images for the various weather conditions can be found at http://openweathermap.org/weather-conditions, but I've put them in a [zip file](assets/weather-icons.zip) for you. You can just unzip that and drag the whole folder into Images.xcassets.

We need to update WeatherAPI to capture the icon code. In the Weather struct, add:

~~~ swift
var icon: String
~~~

and in `weatherFromJSONData`, add that to the Weather initialization:

~~~ swift
var weather = Weather(
    city: json["name"] as String,
    currentTemp: mainDict["temp"] as Float,
    conditions: weatherDict["main"] as String,
    icon: weatherDict["icon"] as String
)
~~~

Now in the `update` method of WeatherView, add:

~~~ swift
imageView.image = NSImage(named: weather.icon)
~~~

That's it! Run it.

## Preferences

Having the city hard-coded in the app is not cool. Let's make a Preferences pane so we can change it.

Open up MainMenu.xib and drag another MenuItem onto the menu, above Quit, naming it "Preferences...".

Open up the Assistant editor again with StatusMenuController, and ctrl-drag from the Preferences menu item over to the code and create a "preferencesClicked" action.

New -> File -> Source -> Cocoa Class. Call it "PreferencesWindow", set the subclass to NSWindowController, and check the box to create a XIB file.

Give the window a title of Preferences. Add a label for "City:", and put a Text Field to the right of it. It should look something like this:

![](assets/preferences.png)

Bring up the Assistant editor with PreferencesWindow.swift and ctrl-drag from the text field to the code and create an outlet named "cityTextField".

In PreferencesWindow.swift, add:

~~~ swift
override var windowNibName : String! {
    return "PreferencesWindow"
}
~~~

and at the end of `windowDidLoad()`, add:

~~~ swift
self.window?.center()
~~~

In StatusMenuController.swift, add a `preferencesWindow` class var:

~~~ swift
var preferencesWindow: PreferencesWindow!
~~~

and initialize in `awakeFromNib()`, before the call to `updateWeather()`:

~~~ swift
preferencesWindow = PreferencesWindow()
~~~

Finally, in the `preferencesClicked` function, add:

~~~ swift
preferencesWindow.showWindow(nil)
~~~

If you run now, selecting the Preferences... menu item should bring up the preferences window.

Now, let's actually save and update the city.

Make the PreferencesWindow class an `NSWindowDelegate`:

~~~ swift
class PreferencesWindow: NSWindowController, NSWindowDelegate {
~~~

and add:

~~~ swift
func windowWillClose(notification: NSNotification) {
    NSLog("city is: " + cityTextField.stringValue)
}
~~~

If you run it now, you'll see whatever you typed in the text field displayed when you close the window.

Saving the value is easy:

~~~ swift
func windowWillClose(notification: NSNotification) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setValue(cityTextField.stringValue, forKey: "city")
}
~~~

Now we need to notify the StatusMenuController that the preferences have been updated. For this we'll use the Delegate pattern. This is easy, but requires a number of edits. First, at the top of PreferencesWindow.swift, add a `PreferencesWindowDelegate` protocol:

~~~ swift
protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}
~~~

and add a `delegate` instance variable:

~~~ swift
var delegate: PreferencesWindowDelegate?
~~~

At the end of `windowWillClose`, we'll call the delegate:

~~~ swift
delegate?.preferencesDidUpdate()
~~~

Back in StatusMenuController, make it a `PreferencesWindowDelegate`:

~~~ swift
class StatusMenuController: NSObject, PreferencesWindowDelegate {
~~~

and add the delegate method:

~~~ swift
func preferencesDidUpdate() {
    updateWeather()
}
~~~

And in `awakeFromNib`, set the delegate:

~~~ swift
preferencesWindow = PreferencesWindow()
preferencesWindow.delegate = self
~~~

All that's left is to load the city from defaults. First add this at the top of StatusMenuController, under the imports:

~~~ swift
let DEFAULT_CITY = "Seattle, WA"
~~~

(...or whatever you want the default to be.) Yes, this is a global variable, and there are probably better ways to do this (like storing it in Info.plist), but that can be left as an exercise for the reader.

Load the saved city, or default, in `updateWeather`:

~~~ swift
func updateWeather() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let city = defaults.stringForKey("city") ?? DEFAULT_CITY
    weatherAPI.fetchWeather(city) { weather in
        self.weatherView.update(weather)
    }
}
~~~

Finally, back in PreferencesWindow.swift, we need to add similar code to load any saved city when we show the preferences. At the end of `windowDidLoad`, add:

~~~ swift
let defaults = NSUserDefaults.standardUserDefaults()
let city = defaults.stringForKey("city") ?? DEFAULT_CITY
cityTextField.stringValue = city
~~~

Run it!

## Next Steps

That's the end of this tutorial. Obviously there's a lot more that we can do with this, but I'll leave that up to you. Some ideas:

- Easy
    + Add other weather info (high/low temp, humidity, sunrise/sunset, etc) to the Weather View
    + Change the status menu icon + title to reflect the current conditions
    + Make it so clicking on the Weather View opens a browser with detailed weather information (easy, if you have a url to go to; hint: `NSWorkspace.sharedWorkspace().openURL(url: NSURL)`)
- More Challenging
    + Add support for multiple cities. This will take some effort, especially if the number of cities is dynamic. I think you'll have to put the Weather View in its own XIB, and load it manually (look at `NSBundle.mainBundle().loadNibNamed(name, owner: owner, options: options)`). The UI in Preferences will need to be updated as well.
- You Know Way More Than Me Now
    + Create a completely custom view when clicking on the app in the status bar. See the [Weather Live](https://itunes.apple.com/us/app/weather-live/id755717884?mt=12) app, for example. I haven't tried this, but I suspect it is easier than you might think (depending on how fancy your view is, of course).

## Resources

- [The Swift Programming Language](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/)
    + Apple's documentation, also downloadable as a [free iBook](https://itunes.apple.com/us/book/the-swift-programming-language/id881256329?mt=11)
- [Mac Dev Center](https://developer.apple.com/devcenter/mac/)
    + Mac developer account is free, but you need to pay $99/year if you want to distribute your app in the app store.
- [OS X Human Interface Guidelines](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/)''