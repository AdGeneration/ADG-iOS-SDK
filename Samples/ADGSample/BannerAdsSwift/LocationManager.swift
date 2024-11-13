//
//  LocationManager.swift
//  ADGSample
//
//  Copyright © 2024 Supership Inc. All rights reserved.
//

import CoreLocation
import UIKit

private let nextLocationUpdateInterval: TimeInterval = 60.0 * 10.0 // 10 minutes

/// 位置情報取得のサンプルコードです。
/// このサンプルコードは、10分間隔で位置情報を更新します
class LocationProvider: NSObject {
    static let shared = LocationProvider()

    private let locationManager: CLLocationManager
    private var lastKnownLocation: CLLocation?
    private var updateTimer: Timer?

    weak var delegate: LocationProviderDelegate?

    override private init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground),
                                               name: Notification.Name
                                                   .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground),
                                               name: Notification.Name
                                                   .UIApplicationDidEnterBackground,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopUpdatingLocation()
    }

    @objc private func appWillEnterForeground() {
        if lastKnownLocation == nil || lastKnownLocation!.timestamp
            .timeIntervalSinceNow > nextLocationUpdateInterval
        {
            print("Schedule location update.")
            scheduleLocationUpdate()
        } else {
            print("Start updating location immediately.")
            startUpdatingLocation()
        }
    }

    @objc private func appDidEnterBackground() {
        stopUpdatingLocation()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
    {
        print("Changed authorization status: \(status.rawValue)")
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                startUpdatingLocation()
            default:
                break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }

        lastKnownLocation = location
        delegate?.locationProvider(self, didUpdateLocation: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location: \(error)")
    }
}

extension LocationProvider {
    func startUpdatingLocation() {
        guard isAuthorized() else {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        guard updateTimer?.isValid != true else {
            print("Already scheduled.")
            return
        }

        locationManager.requestLocation()
        scheduleLocationUpdate()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        updateTimer?.invalidate()
        updateTimer = nil
    }
}

private extension LocationProvider {
    private func isAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }

    private func scheduleLocationUpdate() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: nextLocationUpdateInterval,
                                           repeats: true)
        { [weak self] _ in
            self?.locationManager.requestLocation()
        }
    }
}

protocol LocationProviderDelegate: AnyObject {
    func locationProvider(_ provider: LocationProvider, didUpdateLocation location: CLLocation)
}
