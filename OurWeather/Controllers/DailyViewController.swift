//
//  DailyViewController.swift
//  OurWeather
//
//  Created by Gilang Persada on 08/11/2021.
//

import UIKit

class DailyViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var background: UIImageView!
    
    var dailyWeather: [DailyWeather] = []
    var city:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        if let city = self.city{
            cityLabel.text = city
        }
        
        let nib = UINib(nibName: "DailyCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "dailyCell")
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        let dayNightFormat = Int(formatter.string(from: currentDateTime))
        if let dayNight = dayNightFormat{
            switch dayNight {
            case 0..<7:
                background.image = UIImage(named: "bg2")
            case 18..<25:
                background.image = UIImage(named: "bg2")
            default:
                background.image = UIImage(named: "bg")
            }
        }
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

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

extension DailyViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dailyCell", for: indexPath) as! DailyCell
        
        cell.dateLabel.text = dailyWeather[indexPath.row].date
        cell.dayLabel.text = dailyWeather[indexPath.row].day
        cell.descLabel.text = dailyWeather[indexPath.row].desc
        cell.tempLabel.text =  dailyWeather[indexPath.row].tempString
        cell.iconImage.image = UIImage(named: getWeatherIcon(id: dailyWeather[indexPath.row].conditionID))
        
        return cell
    }
    
    
}
