//
//  DailyTableViewCell.swift
//  WeatherApp_Final
//
//  Created by Steven  Manno on 12/17/22.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var dailyImageView: UIImageView!
    @IBOutlet weak var dailyWeekdayLabel: UILabel!
    @IBOutlet weak var dailyHighLabel: UILabel!
    @IBOutlet weak var dailyLowLabel: UILabel!
    @IBOutlet weak var dailyDescriptionTextView: UITextView!
    
    
    var dailyWeather: DailyWeather! {
        didSet{
            dailyImageView.image = UIImage(systemName: dailyWeather.dailyIcon)?.withRenderingMode(.alwaysOriginal)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailyDescriptionTextView.text = dailyWeather.dailyDescription
            dailyHighLabel.text = "\(dailyWeather.dailyHigh)°"
            dailyLowLabel.text = "\(dailyWeather.dailyLow)°"
            
        }
    }
    
    

}
