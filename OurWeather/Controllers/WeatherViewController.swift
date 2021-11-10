//
//  ViewController.swift
//  OurWeather
//
//  Created by Gilang Persada on 04/11/2021.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Enter a city name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1, alpha: 0.7)])
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let locationManager = CLLocationManager()
    private var weatherManager = WeatherManager()
    private var weather:WeatherModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(self.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        searchTextField.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        weatherManager.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        let formatter2 = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter2.dateFormat = "HH"
        let dateString = formatter.string(from: currentDateTime)
        dateLabel.text = "Today, \(dateString)"
        
        let nib = UINib(nibName: "HourlyCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "hourlyCell")
        
        let dayNightFormat = Int(formatter2.string(from: currentDateTime))
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
    
    @objc func dismissKeyboard()
    {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
    }

    @IBAction func searchButton(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        isLoading()
        locationManager.requestLocation()
    }
    
    func isLoading() {
        topStack.isHidden = true
        contentStack.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func finishLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        topStack.isHidden = false
        contentStack.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDaily"{
            let vc = segue.destination as? DailyViewController
            if let weather = weather{
                vc?.dailyWeather = weather.daily
            }
            if let city = cityLabel.text{
                vc?.city = city
            }
        }
    }
    
}



extension WeatherViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != ""{
//            return true
//        } else {
//            textField.placeholder = "Enter a city name"
//            return false
//        }
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text{
            if text != ""{
                isLoading()
                weatherManager.fetchGeocode(cityName: text)
                textField.text = ""
            }
        }
    }
    
}

extension WeatherViewController: WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherLabel.text = weather.current.desc
            self.temperatureLabel.text = "\(weather.current.temperatureString)°"
            self.humidityLabel.text = "\(weather.current.humidityString) %"
            self.windLabel.text = "\(weather.current.windString) m/s"
            self.iconImage.image = UIImage(named: weather.getWeatherIcon(id: weather.current.conditionId))
            self.weather = weather
            self.collectionView.reloadData()
            self.finishLoading()
        }
    }
    
    func didUpdateGeocode(_ weatherManager: WeatherManager, geocode: GeocodeModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = geocode.name
            weatherManager.fetchWeather(lat: geocode.lat, lon: geocode.lon)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.finishLoading()
        }
        
    }
    
    func didFailWithError(error: String) {
        print(error)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.finishLoading()
        }
        
    }
    
    
}

extension WeatherViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchGeocode(lat: lat, lon: lon)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return weather?.hourly.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath) as! HourlyCell
        
        if let weather = weather{
            cell.timeLabel.text = weather.hourly[indexPath.row].timeString
            cell.temperatureLabel.text = "\(weather.hourly[indexPath.row].temperatureString)°"
            cell.iconImage.image = UIImage(named: weather.getWeatherIcon(id: weather.hourly[indexPath.row].id))
        }
        
        return cell
    }
    
    
}



