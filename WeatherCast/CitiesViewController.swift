//
//  CitiesViewController.swift
//  WeatherCast
//
//  Created by Ketul Chauhan on 2023-08-03.
//

import UIKit

class CitiesViewController: UIViewController {
    var allCitiesSearched:[ WeatherModel] = []
    var userTempratureUnitSelected = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting datasource to self
        tableView.dataSource = self
    }
}

extension CitiesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCitiesSearched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        let city = allCitiesSearched[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        //Setting City Name
        content.text = city.cityName
        
        //Setting Temprature
        if(userTempratureUnitSelected == "celsius"){
            content.secondaryText = "\(city.tempratureInCelsius)\("º C")"
        }else{
            content.secondaryText = "\(city.tempratureInFahrenheit)\("º F")"
        }
        
        //Setting icon with 2 colors
        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
        content.image = UIImage(systemName: city.weatherIconName)
        content.image = content.image?.applyingSymbolConfiguration(config)
        
        cell.contentConfiguration = content
        return cell
    }
}
 
