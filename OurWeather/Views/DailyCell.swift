//
//  DailyCell.swift
//  OurWeather
//
//  Created by Gilang Persada on 08/11/2021.
//

import UIKit

class DailyCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        background.layer.cornerRadius = 15
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        let dayNightFormat = Int(formatter.string(from: currentDateTime))
        if let dayNight = dayNightFormat{
            switch dayNight {
            case 0..<7:
                background.image = UIImage(named: "bg")
            case 18..<25:
                background.image = UIImage(named: "bg")
            default:
                background.image = UIImage(named: "bg2")
            }
        }
    }

}
