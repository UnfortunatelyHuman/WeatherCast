//
//  WeatherModel.swift
//  WeatherCast
//
//  Created by Ketul Chauhan on 2023-08-04.
//

import Foundation

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
