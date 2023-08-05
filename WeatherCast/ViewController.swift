//
//  ViewController.swift
//  WeatherCast
//
//  Created by Ketul Chauhan on 2023-08-01.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    //API Key
    let key = "1aab60093432467ba0f204559230108"
    
    //This array will store all the searched cities objects
    var allCitiesSearched:[WeatherModel] = []
    
    //User selected temperature unit
    var currentTemperatureUnit = ""
    var currentWeatherTemp = -1
    var currentWeatherInCelsius = 0.0
    var currentWeatherInFahrenheit = 0.0

    //Main Structure For Parsing Data From API
    struct WeatherData: Decodable{
        let location: Location
        let current: Current
    }

    //Location Structure For WeatherData
    struct Location: Decodable{
        let name: String
        let lat: Double
        let lon: Double
    }

    //Current Structure For WeatherData
    struct Current: Decodable{
        let temp_c: Double
        let temp_f: Double
        let condition: Condition
    }

    //Condition Fot Current Structure
    struct Condition: Decodable{
        let code: Int
    }

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var currentTemprature: UILabel!
    @IBOutlet weak var currentTemperatureUnitLabel: UILabel!
    @IBOutlet weak var currentTempratureUnitButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    
    //Location manager for current location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting Default Weather To London Ontario Canada
        let lat = "42.98"
        let lon = "-81.25"
        let url = fetchWeatherURL(cityOrCoordinates: "\(lat),\(lon)")
        fetchWeatherData(urlInput: url)
        
        //Default temp unit
        currentTemperatureUnit = "celsius"
        
        //Using delegate for return click on the keyboard
        searchField.delegate = self
        
        //Location manager delegate
        locationManager.delegate = self
    }

    @IBAction func temperatureUnitChangePressed(_ sender: UIButton) {
        if(currentTemperatureUnit == "celsius"){
            currentTemperatureUnit = "fahrenheit"
            currentTemperatureUnitLabel.text = "Change Unit To Celsius"
            currentTempratureUnitButton.setTitle("C", for: .normal)
            currentTempratureUnitButton.backgroundColor = UIColor.systemOrange
            currentTemperatureUnitLabel.textColor = UIColor.systemOrange
            
            if(currentWeatherTemp != -1){
                currentTemprature.text = "\(currentWeatherInFahrenheit)\("º F")"
            }
            
        }else{
            currentTemperatureUnit = "celsius"
            currentTemperatureUnitLabel.text = "Change Unit To Fahrenheit"
            currentTempratureUnitButton.setTitle("F", for: .normal)
            currentTempratureUnitButton.backgroundColor = UIColor.systemBlue
            currentTemperatureUnitLabel.textColor = UIColor.systemBlue
            
            if(currentWeatherTemp != -1){
                currentTemprature.text = "\(currentWeatherInCelsius)\("º C")"
            }
        }
    }
    
    @IBAction func searchIconPressed(_ sender: UIButton) {
        //To close keyboard
        searchField.endEditing(true)
        let city = searchField.text ?? "London-Ontario-Canada"
        let url = fetchWeatherURL(cityOrCoordinates: city)
        fetchWeatherData(urlInput: url)
    }
    
    //This funciton will be called when user clicks on enter button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //To close keyboard
        searchField.endEditing(true)
        print(searchField.text ?? "")
        return true
    }
    
    @IBAction func currentLocationIconPressed(_ sender: UIButton) {
        //Requesting location permission
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            let url = fetchWeatherURL(cityOrCoordinates: "\(lat),\(lon)")
            fetchWeatherData(urlInput: url)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
    
    @IBAction func citiesButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCitiesScreen", sender: self)
    }
    
    //This will copy allCitiesSearched to the segue viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! CitiesViewController
        viewController.allCitiesSearched = allCitiesSearched
        viewController.userTempratureUnitSelected = currentTemperatureUnit
    }
    
    //This function will return the url with the city or the coordinate
    func fetchWeatherURL(cityOrCoordinates: String) -> String{
        let baseURL = "https://api.weatherapi.com/v1/current.json?key=\(key)&q=\(cityOrCoordinates)"
        return baseURL
    }
    
    //This function will fetch JSON data from the API
    func fetchWeatherData(urlInput:String){
        //1. Create a URL
        if let url = URL(string: urlInput){
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.updateUI(weather: weather)
                    }
                }
            })
            
            //4. Start the task
            task.resume()
        }
    }
    
    //Updates UI with fetched data
    func updateUI(weather: WeatherModel){
        //Adding weather objects inside allCitiesSearched
        allCitiesSearched.append(weather)
        
        //Updating UI Elements
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.weatherLabel.text = weather.weatherConditionName
            
            if(self.currentTemperatureUnit == "celsius"){
                self.currentTemprature.text = "\(weather.tempratureInCelsius)\("º C")"
            }else{
                self.currentTemprature.text = "\(weather.tempratureInFahrenheit)\("º F")"
            }
            self.currentWeatherTemp = 1
            self.currentWeatherInCelsius = weather.tempratureInCelsius
            self.currentWeatherInFahrenheit = weather.tempratureInFahrenheit
            
            //This will set the corresponding image to the view with 2 colors
            let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
            self.weatherImage.preferredSymbolConfiguration = config
            self.weatherImage.image = UIImage(systemName: weather.weatherIconName)
        }
    }
    
    //This function will parse data recieved from the API
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let cityName = decodedData.location.name
            let cityLAT = decodedData.location.lat
            let cityLON = decodedData.location.lon
            let tempratureInCelsius = decodedData.current.temp_c
            let tempratureInFahrenheit = decodedData.current.temp_f
            let weatherConditionCode = decodedData.current.condition.code
            let weatherConditionName = getWeatherConditionName(conditionCode: decodedData.current.condition.code)
            let weatherIconName = self.getWeatherImageIconName(weatherConditionCode: weatherConditionCode)
            
            let weather = WeatherModel(cityName: cityName, cityLAT: cityLAT, cityLON: cityLON, tempratureInCelsius: tempratureInCelsius, tempratureInFahrenheit: tempratureInFahrenheit, weatherConditionCode: weatherConditionCode, weatherConditionName: weatherConditionName, weatherIconName: weatherIconName)
            
            return weather
        }catch {
            print(error)
            return nil
        }
    }
    
    //This will return symbol name to be used depending on the weather condition
    func getWeatherImageIconName(weatherConditionCode: Int) -> String{
        switch weatherConditionCode {
        case 1000:
            return "sun.max.circle.fill"
        case 1003:
            return "cloud.sun.circle.fill"
        case 1006:
            return "cloud.circle.fill"
        case 1009:
            return "smoke.circle.fill"
        case 1030:
            return "cloud.fog.circle.fill"
        case 1063, 1180:
            return "cloud.sun.rain.circle.fill"
        case 1066, 1210, 1069, 1204, 1207, 1237, 1249, 1252, 1261, 1264, 1072, 1150, 1153, 1168, 1171:
            return "cloud.sleet.circle.fill"
        case 1087, 1273, 1276:
            return "cloud.bolt.rain.circle.fill"
        case 1114:
            return "wind.snow.circle.fill"
        case 1117, 1213, 1216, 1219, 1222, 1225, 1255, 1258, 1279, 1282:
            return "snowflake.circle.fill"
        case 1135, 1147:
            return "cloud.fog.circle.fill"
        case 1183, 1186, 1189, 1192, 1198, 1201, 1240, 1243, 1246:
            return "cloud.sun.rain.circle.fill"
        case 1195:
            return "cloud.heavyrain.circle.fill"
        default:
            return "sun.max.circle.fill"
        }
    }
    
    //This will return weather name from the weather code
    func getWeatherConditionName(conditionCode: Int) -> String{
        switch conditionCode{
        case 1000: return "Sunny"
        case 1003: return "Partly cloudy"
        case 1006: return "Cloudy"
        case 1009: return "Overcast"
        case 1030: return "Mist"
        case 1063: return "Patchy rain possible"
        case 1066: return "Patchy snow possible"
        case 1069: return "Patchy sleet possible"
        case 1072: return "Patchy freezing drizzle possible"
        case 1087: return "Thundery outbreaks possible"
        case 1114: return "Blowing snow"
        case 1117: return "Blizzard"
        case 1135: return "Fog"
        case 1147: return "Freezing fog"
        case 1150: return "Patchy light drizzle"
        case 1153: return "Light drizzle"
        case 1168: return "Freezing drizzle"
        case 1171: return "Heavy freezing drizzle"
        case 1180: return "Patchy light rain"
        case 1183: return "Light rain"
        case 1186: return "Moderate rain at times"
        case 1189: return "Moderate rain"
        case 1192: return "Heavy rain at times"
        case 1195: return "Heavy rain"
        case 1198: return "Light freezing rain"
        case 1201: return "Moderate or heavy freezing rain"
        case 1204: return "Light sleet"
        case 1207: return "Moderate or heavy sleet"
        case 1210: return "Patchy light snow"
        case 1213: return "Light snow"
        case 1216: return "Patchy moderate snow"
        case 1219: return "Moderate snow"
        case 1222: return "Patchy heavy snow"
        case 1225: return "Heavy snow"
        case 1237: return "Ice pellets"
        case 1240: return "Light rain shower"
        case 1243: return "Moderate or heavy rain shower"
        case 1246: return "Torrential rain shower"
        case 1249: return "Light sleet showers"
        case 1252: return "Moderate or heavy sleet showers"
        case 1255: return "Light snow showers"
        case 1258: return "Moderate or heavy snow showers"
        case 1261: return "Light showers of ice pellets"
        case 1264: return "Moderate or heavy showers of ice pellets"
        case 1273: return "Patchy light rain with thunder"
        case 1276: return "Moderate or heavy rain with thunder"
        case 1279: return "Patchy light snow with thunder"
        case 1282: return "Moderate or heavy snow with thunder"
        default:
            return "ERROR"
        }
    }
}

