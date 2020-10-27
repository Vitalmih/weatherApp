//
//  WeatherManager.swift
//  weather
//
//  Created by Виталий on 27.10.2020.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpadateWeather(weather: WeatherModel)
    
    func didFailWithErroe(error: Error)
}

struct WeatherManager {
    
    let openWeatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=995e98a9e4df40949b5d5f5314e2274b&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func getWeather(cityName: String) {
        let urlString = "\(openWeatherURL)&q=\(cityName)"
        performeRequest(with: urlString)
    }
    
    func getWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(openWeatherURL)&lat=\(latitude)&lon=\(longitude)"
        performeRequest(with: urlString)
    }
    
    func performeRequest(with urlString: String) {
        
        guard let url = URL(string: urlString) else {return}
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithErroe(error: error!)
                return
            }
            guard let safeData = data else {return}
            parseJSONdata(safeData)
        }
        task.resume()
    }
    
    func parseJSONdata (_ weatherData: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weather = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name, temperature: decodedData.main.temp)
            delegate?.didUpadateWeather(weather: weather)
        } catch {   
            delegate?.didFailWithErroe(error: error)
        }
    }
}
