//
//  WeatherManager.swift
//  OurWeather
//
//  Created by Gilang Persada on 05/11/2021.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didUpdateGeocode(_ weatherManager: WeatherManager, geocode: GeocodeModel)
    func didFailWithError(error: Error)
    func didFailWithError(error: String)
}

struct WeatherManager {
    private let oneCallApi = "https://api.openweathermap.org/data/2.5/onecall?&appid=223c5b87825825338bbf3eb6cc4b5d93&units=metric"
    private let reverseApi = "https://api.openweathermap.org/geo/1.0/reverse?appid=223c5b87825825338bbf3eb6cc4b5d93"
    private let geocodeApi = "https://api.openweathermap.org/geo/1.0/direct?appid=223c5b87825825338bbf3eb6cc4b5d93"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchGeocode(cityName:String) {
        let urlString = "\(geocodeApi)&q=\(cityName)"
////        let safeURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        if let url = safeURL{
            performRequest(urlString: urlString, isFetchWeather: false)
//        }
    }
    
    func fetchGeocode(lat:CLLocationDegrees, lon:CLLocationDegrees) {
        let urlString = "\(reverseApi)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString: urlString, isFetchWeather: false)
    }
    
    func fetchWeather(lat:CLLocationDegrees, lon:CLLocationDegrees) {
        let urlString = "\(oneCallApi)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString: urlString, isFetchWeather: true)
    }
    
    private func performRequest(urlString:String, isFetchWeather:Bool) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let err = error{
                    print(err.localizedDescription)
                    self.delegate?.didFailWithError(error: err)
                }
                if let safeData = data{
                    if isFetchWeather{
                        if let weather = parsedWeatherJson(weatherData: safeData){
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    } else{
                        if let geocode = parsedGeocodeJson(geocodeData: safeData){
                            self.delegate?.didUpdateGeocode(self, geocode: geocode)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parsedWeatherJson(weatherData:Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.current.weather[0].id
            let desc = decodedData.current.weather[0].main
            let temp = decodedData.current.temp
            let humidity = decodedData.current.humidity
            let wind = decodedData.current.wind_speed
            
            let currentWeather = CurrentWeather(conditionId: id, temperature: temp, desc: desc, wind: wind, humidity: humidity)
            
            let hourly:[Hourly] = decodedData.hourly
            var hourlyWeather:[HourlyWeather] = []
            
            for i in 0...11{
                hourlyWeather.append(HourlyWeather(time: hourly[i].dt, temp: hourly[i].temp, id: hourly[i].weather[0].id, desc: hourly[i].weather[0].main))
            }
            
            let daily:[Daily] = decodedData.daily
            var dailyWeather:[DailyWeather] = []
            
            for i in daily{
                dailyWeather.append(DailyWeather(time: i.dt, day_temp: i.temp.day, night_temp: i.temp.night, conditionID: i.weather[0].id, desc: i.weather[0].main))
            }
            
            let weather = WeatherModel(current: currentWeather, hourly: hourlyWeather, daily: dailyWeather)
            
            return weather
            
        } catch{
            print(error.localizedDescription)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    private func parsedGeocodeJson(geocodeData:Data) -> GeocodeModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode([GeocodeData].self, from: geocodeData)
            if decodedData.isEmpty {
                delegate?.didFailWithError(error: "City Not Found")

                return nil
            } else {
                let name = decodedData.first!.name
                let lat = decodedData.first!.lat
                let lon = decodedData.first!.lon
                let country = decodedData.first!.country
                let geocode = GeocodeModel(name:name, lat: lat, lon: lon, country: country)
                

                return geocode
            }
            
        } catch{
            print(error.localizedDescription)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
