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
    
    //User selected temperature unit
    var currentTemperatureUnit = ""
    var currentWeatherTemp = -1
    var currentWeatherInCelsius = 0.0
    var currentWeatherInFahrenheit = 0.0
    
    //Main Object To Store All Information At One Place
    struct WeatherModel{
        let cityName: String
        let cityLAT: Double
        let cityLON: Double
        let tempratureInCelsius: Double
        let tempratureInFahrenheit: Double
        let weatherConditionCode: Int
        let weatherConditionName: String
        let weatherIconName: String
    }

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
        print("Search Button Pressed")
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
                        print("WeatherData Fetched: \(weather)")
                        
                        //TODO: weather object has all the data that will be enough to update UI
                    }
                }
            })
            
            //4. Start the task
            task.resume()
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
            
            //TODO: Fetch Condition Name And Icon Name From API
            let weatherConditionName = "Sunny"
            let weatherIconName = "sun.max.circle.fill"
            
            let weather = WeatherModel(cityName: cityName, cityLAT: cityLAT, cityLON: cityLON, tempratureInCelsius: tempratureInCelsius, tempratureInFahrenheit: tempratureInFahrenheit, weatherConditionCode: weatherConditionCode, weatherConditionName: weatherConditionName, weatherIconName: weatherIconName)
            
            return weather
        }catch {
            print(error)
            return nil
        }
    }
}

