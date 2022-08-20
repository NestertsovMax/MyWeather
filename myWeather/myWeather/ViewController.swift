//
//  ViewController.swift
//  myWeather
//
//  Created by M1 on 12.08.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    
    var models = [Daily]()
    var hourlyModels = [Current]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: Current?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    // Location
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?&lat=\(lat)&lon=\(long)&appid=a2c267fd0fba1e77732e4f00e2fbeca1&units=metric")
        
        URLSession.shared.dataTask(with: url!, completionHandler:  { data, response, error in
            // Validation
            
            guard let data = data, error == nil else {
                print("some went wrong")
                return
            }

            
            // Convert data to models/some obj
            
            var json: WeatherResponse?
            do{
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }
            
            guard let result = json else {
                return
            }

            let entries = result.daily

            self.models.append(contentsOf: entries)
            
            let current = result.current
            self.current = current
            
            self.hourlyModels = result.hourly
            
            
            //Update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
                
                self.table.tableHeaderView = self.createTableHeader()
            }
            
        }).resume()
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2))
        headerView.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: CGFloat(Int(20+locationLabel.frame.size.height+summaryLabel.frame.size.height)), width: view.frame.width-20, height: headerView.frame.size.height/2))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        guard let currentWeather = current else { return UIView() }
        let geoCoder = CLGeocoder()
        if let currentLocation = currentLocation {
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            if let city = placeMark.subAdministrativeArea {
            locationLabel.text = city
            }
        })
        }
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        tempLabel.text = "\(Int(currentWeather.temp))°"
        if let summaryText = currentWeather.weather.first?.main.rawValue {
            summaryLabel.text = summaryText
        }
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        return cell
    }
}

struct WeatherResponse: Codable {
    let lat, lon: Double
    let timezone: String
    let current: Current
    let hourly: [Current]
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case current, hourly, daily
    }
}

struct Current: Codable {
    let dt: Int
    let sunrise, sunset: Int?
    let temp: Double
    let clouds, visibility: Int
    let weather: [Weather]
    let pop: Double?
    let rain: Rain?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case clouds, visibility
        case weather
        case pop, rain
    }
}
enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

enum Description: String, Codable {
    case brokenClouds = "broken clouds"
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case lightRain = "light rain"
    case moderateRain = "moderate rain"
    case overcastClouds = "overcast clouds"
    case scatteredClouds = "scattered clouds"
}
struct Daily: Codable {
    let dt, sunrise, sunset, moonrise: Int
    let temp: Temp
    let weather: [Weather]
    let clouds: Int
    let pop, uvi: Double
    let rain: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise
        case temp
        case weather, clouds, pop, uvi, rain
    }
}
struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}
struct Rain: Codable {
    let the1H: Double

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}
struct Weather: Codable {
    let id: Int
    let main: Main
    let weatherDescription: Description
    let icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}
