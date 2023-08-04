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
                    print("Data Fetched From URL: \(safeData)")
                    //TODO: Create A Function That Parses JSON and Update UI Elements.....
                }
            })
            
            //4. Start the task
            task.resume()
        }
    }
}

