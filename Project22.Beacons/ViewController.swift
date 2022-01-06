//
//  ViewController.swift
//  Project22.Beacons
//
//  Created by Igor Polousov on 20.12.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    // Надпись на экране
    @IBOutlet var distanceReading: UILabel!
    // Менеджер положения: начинает и останавливает предоставлениеданных о местоположении
    var locationManager: CLLocationManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Создан экземпляр location manager
        locationManager = CLLocationManager()
        // Предоставляться информация о местоположении будет в location manager
        locationManager?.delegate = self
        // Запрос пользователя на получение местоположения
        locationManager?.requestAlwaysAuthorization()
        // Сделан серый фон
        view.backgroundColor = .gray
    }

    // Проверка авторизации и возможностей сканирования устройством
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Если есть авторизация на местоположение
        if status == .authorizedAlways {
            // Проверка на доступность функции определения местоположения
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                // Проверка на возможность поиска маяков
                if CLLocationManager.isRangingAvailable() {
                    // Если три проверки пройдены, начать сканирование
                    startScanning()
                }
            }
        }
    }
    
    // Поиск устройства с заданными характеристиками
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    // При обнаружении устройства меняет цвет фона и надпись на экране
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                
           default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }

}

