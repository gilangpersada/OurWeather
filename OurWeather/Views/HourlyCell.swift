//
//  HourlyCell.swift
//  OurWeather
//
//  Created by Gilang Persada on 05/11/2021.
//

import UIKit

class HourlyCell: UICollectionViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var backgroun: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroun.layer.cornerRadius = 15
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        let dayNightFormat = Int(formatter.string(from: currentDateTime))
        if let dayNight = dayNightFormat{
            switch dayNight {
            case 0..<7:
                backgroun.image = UIImage(named: "bg")
            case 18..<25:
                backgroun.image = UIImage(named: "bg")
            default:
                backgroun.image = UIImage(named: "bg2")
            }
        }
    }

}
