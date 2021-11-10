//
//  WeatherModel.swift
//  OurWeather
//
//  Created by Gilang Persada on 05/11/2021.
//

import Foundation

struct WeatherModel{
    let current:CurrentWeather
    let hourly:[HourlyWeather]
    let daily:[DailyWeather]
    
    func getWeatherIcon(id: Int) -> String {
        
        switch id {
        case 200...232:
            return "thunderstorm"
        case 300...321:
            return "rain"
        case 500...531:
            return "rain"
        case 600...622:
            return "snow"
        case 701...781:
            return "mist"
        case 800:
            return "clear"
        case 801...804:
            return "cloudy"
        default:
            return "cloudy"
        }
        
    }
}

struct CurrentWeather {
    let conditionId: Int
    let temperature: Double
    let desc: String
    let wind: Double
    let humidity: Double
    
    var humidityString: String {
        return String(format: "%.0f", humidity)
    }
    
    var windString: String {
        return String(format: "%.1f", wind)
    }
    var temperatureString: String {
        return String(format: "%.0f", temperature)
    }
}

struct HourlyWeather {
    let time : Double
    let temp: Double
    let id: Int
    let desc: String
    
    var timeString: String {
        let date = Date(timeIntervalSince1970: time)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: date)
        
    }
    
    var temperatureString: String {
        return String(format: "%.0f", temp)
    }
}

struct DailyWeather {
    let time: Double
    let day_temp: Double
    let night_temp: Double
    let conditionID: Int
    let desc: String
    
    
    
    var day: String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    var date: String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: date)
    }
    
    var tempString: String {
        return "\(String(format: "%.0f", day_temp))°/\(String(format: "%.0f", night_temp))°"
    }
    
    
}
