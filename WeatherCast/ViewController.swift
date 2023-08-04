//
//  ViewController.swift
//  WeatherCast
//
//  Created by Ketul Chauhan on 2023-08-01.
//

import UIKit

class ViewController: UIViewController {
    //User selected temperature unit
    var currentTemperatureUnit = ""
    var currentWeatherTemp = -1
    var currentWeatherInCelsius = 0.0
    var currentWeatherInFahrenheit = 0.0

    @IBOutlet weak var searchField: UIButton!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var currentTemprature: UILabel!
    @IBOutlet weak var currentTemperatureUnitLabel: UILabel!
    @IBOutlet weak var currentTempratureUnitButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Default temp unit
        currentTemperatureUnit = "celsius"
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
    
    
    @IBAction func currentLocationIconPressed(_ sender: UIButton) {
        print("Current Location Icon Pressed")
    }
    
    
    @IBAction func citiesButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCitiesScreen", sender: self)
    }
}

