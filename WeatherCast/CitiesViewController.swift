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
        print(allCitiesSearched)
    }
}
