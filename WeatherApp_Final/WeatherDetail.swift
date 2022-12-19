//
//  WeatherDetail.swift
//  WeatherApp_Final
//
//  Created by Steven  Manno on 12/17/22.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()

private let hourFormatter: DateFormatter = {
    let hourFormatter = DateFormatter()
    hourFormatter.dateFormat = "ha"
    return hourFormatter
}()

struct DailyWeather{
    var dailyIcon: String
    var dailyWeekday: String
    var dailyDescription: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather{
    var hour: String
    var hourlyTemperature: Int
    var hourlyIcon: String
}

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable{
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    private struct Current: Codable{
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable{
        var description: String
        var icon: String
    }
    
    private struct Daily: Codable{
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    private struct Hourly: Codable{
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Temp: Codable{
        var max: Double
        var min: Double
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dayIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
    func getData(completed: @escaping () -> ()){
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIkeys.weatherMapAPIKey)"
        
        //Create a URL
        guard let url = URL(string: urlString) else{
            print("Error: Could not create a URL from \(urlString)")
            completed()
            return
        }
        
        //Create URLSession
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dayIcon = self.nameForIcon(icon: result.current.weather[0].icon)
                
                for index in 0..<result.daily.count{
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    let dailyIcon = self.nameForIcon(icon: result.daily[index].weather[0].icon)
                    let dailyDescription = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailyDescription: dailyDescription, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                }
                //get no more than 24 hours of data
                //start at the next hour
                let lastHour = min(24, result.hourly.count)
                if lastHour > 0{
                    for index in 1...lastHour{
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                        let hour = hourFormatter.string(from: hourlyDate)
                        let hourlyIcon = self.nameForIcon(icon: result.hourly[index].weather[0].icon)
                        let hourlyTemperature = Int(result.hourly[index].temp.rounded())
                        let hourlyWeather = HourlyWeather(hour: hour, hourlyTemperature: hourlyTemperature, hourlyIcon: hourlyIcon)
                        self.hourlyWeatherData.append(hourlyWeather)
                    }
                }
                
            }catch{
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
    private func nameForIcon(icon: String) -> String{
        var newIconName = ""
        switch icon {
        case "01d":
            newIconName = "sun.max.fill"
        case "01n":
            newIconName = "moon.fill"
        case "02d":
            newIconName = "cloud.sun.fill"
        case "02n":
            newIconName = "cloud.moon.fill"
        case "03d", "03n", "04d", "04n":
            newIconName = "cloud.fill"
        case "09d", "09n", "10d", "10n":
            newIconName = "cloud.rain.fill"
        case "11d", "11n":
            newIconName = "cloud.bolt.rain.fill"
        case "13d", "13n":
            newIconName = "cloud.snow.fill"
        case "50d", "50n":
            newIconName = "cloud.fog.fill"
        default:
            newIconName = ""
        }
        return newIconName
    }
}
