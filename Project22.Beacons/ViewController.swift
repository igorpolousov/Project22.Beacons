//
//  ViewController.swift
//  Project22.Beacons
//  Day 75-76
//  Created by Igor Polousov on 20.12.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // view для круга
    @IBOutlet var circleView: UIView!
    // Название найденного устройства
    @IBOutlet var deviceNameLabel: UILabel!
    // Надпись для обозначения дистанции
    @IBOutlet var distanceReading: UILabel!
    // Менеджер положения: начинает и останавливает предоставлениеданных о местоположении
    var locationManager: CLLocationManager?
    //переменная для определения найден маяк или нет
    var isDetected = false
    // проверка уникальности uuid
    var currentBeaconUuid: UUID?
    
    
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
        // начальное название устройства
        deviceNameLabel.text = "Device not detected"
        
        circleView.layer.cornerRadius = 120
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
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
    func startScanning(major:UInt16 = 123, minor:UInt16 = 456) {
        addBeaconRegion(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: major, minor: minor, identifier: "iPad")
        addBeaconRegion(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6", major: major, minor: minor, identifier: "Radius Networks")
        addBeaconRegion(uuidString: "92AB49BE-4127-42F4-B532-90fAF1E26491", major: major, minor: minor, identifier: "TwoCanoes")
    }
    
    // Добавление маяка
    func addBeaconRegion(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        let uuid = UUID(uuidString: uuidString)!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: identifier)
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    // При обнаружении устройства меняет цвет фона и надпись на экране
    func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.deviceNameLabel.text = "\(name)"
            switch distance {
            case .far:
                self?.alertController()
                self?.view.backgroundColor = .blue
                self?.distanceReading.text = "FAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                self?.isDetected = true
            case .near:
                self?.alertController()
                self?.view.backgroundColor = .orange
                self?.distanceReading.text = "NEAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self?.isDetected = true
            case .immediate:
                self?.alertController()
                self?.view.backgroundColor = .red
                self?.distanceReading.text = "RIGHT HERE"
                self?.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self?.isDetected = true
           default:
                self?.view.backgroundColor = .gray
                self?.distanceReading.text = "UNKNOWN"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self?.isDetected = false
            }
        }
    }
    
    // Нужна для обнаружения всех маяков в радиусе действия и добавляет их в массив в случае обнаружения
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity, name: region.identifier)
            
            if currentBeaconUuid == nil { currentBeaconUuid = region.proximityUUID }
            guard currentBeaconUuid == region.proximityUUID else { return }
            
        } else {
            guard currentBeaconUuid == region.proximityUUID else { return }
            currentBeaconUuid = nil
            update(distance: .unknown, name: "Device not detected")
        }
    }
    
    func alertController() {
        if !isDetected {
            let ac = UIAlertController(title: "Device found", message: "Your device was found", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
            present(ac, animated: true)
        }
    }

}

