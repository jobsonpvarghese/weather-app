//
//  ViewController.swift
//  Lab03
//
//  Created by Jobson Varghese on 2022-11-22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temperatureSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        search.delegate = self
        locationManager.delegate = self
    }
    
    // location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {  
    if let location = locations.first {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    let city = placemark.locality ?? ""
                    let country = placemark.country ?? ""
                    self.location.text = "\(city), \(country)"
                    self.getWeatherData(city: city)
                }
            }
    }
   }
    
    //
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @IBAction func onLocationClicked(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        search.text = ""
    }
    
    @IBAction func onClickSearch(_ sender: Any) {
        let city = search.text!
        getWeatherData(city: city)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
    
    // creating url and fetching data
    func getUrl(city: String) -> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let endPoint = "current.json"
        let apiKey = "86274d709ad944b6b13225319222211"
        let params = "q=\(city)"

        guard let url = "\(baseUrl)\(endPoint)?key=\(apiKey)&\(params)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
        return nil
        }
        return URL(string: url)
    }

    // fetching weather data
    func getWeatherData(city: String) {
        let url =  getUrl(city: city)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data, response, error) in
            // network call completed
            if error != nil {
                print(error!)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                let location = json["location"] as! [String: AnyObject]
                let name = location["name"] as! String
                
                let condition = json["current"] as! [String: AnyObject]
                let conditionText = condition["condition"] as! [String: AnyObject]
                let conditionTextString = conditionText["text"] as! String
                
                // rendering image by condition code
                let conditionCode = conditionText["code"] as! Int
               
                let conditionImageString = self.conditionImageCheck(code: conditionCode)
                print(conditionCode)
                
                let tempC = condition["temp_c"] as! Double
                let tempF = condition["temp_f"] as! Double
                DispatchQueue.main.async {
                    self.location.text = "\(name)"
                    self.condition.text = conditionTextString
                  if self.temperatureSwitch.selectedSegmentIndex == 0 {
                    self.temperature.text = "\(tempC)°C"
                  } else {
                    self.temperature.text = "\(tempF)°F"
                    }
                    
                    self.conditionImage.image = UIImage(systemName: conditionImageString)
                }
            } catch let jsonError {
                print(jsonError)
            }
        }
        task.resume()
      
    }
    
    // switch between celsius and fahrenheit
     @IBAction func onClickTempSwitch(_ sender: Any) {
         let city = search.text!
         getWeatherData(city: city)
    }

    // rendering image by condition code
    func conditionImageCheck(code: Int) -> String {
        switch code {
        case 1000:
            return "sun.max"
        case 1003:
            return "cloud.sun"
        case 1006:
            return "cloud"
        case 1009:
            return "cloud.sun.rain"
        case 1030:
            return "cloud.fog"
        case 1063:
            return "cloud.sun.rain"
        case 1066:
            return "cloud.snow"
        case 1069:
            return "cloud.sleet"
        case 1072:
            return "cloud.sleet"
        case 1087:
            return "cloud.sleet"
        case 1114:
            return "wind.snow"
        case 1117:
            return "wind.snow"
        case 1243:
            return "cloud.heavyrain"
        case 1240:
            return "cloud.rain"
        default:
            return "sunny.max"
        }
        
    }

}
