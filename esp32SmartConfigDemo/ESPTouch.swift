//
//  ESPTouchManager.swift
//  esp32SmartConfigDemo
//
//  Created by Doug Inman on 30/10/20.

//  Acknowlegements
//  1. https://github.com/EspressifApp/EsptouchForIOS
//  2. https://github.com/Jowsing/ESPTouchSwift

import Foundation
import EspressifTouchSDK
import CoreLocation

public enum ESPTouchError: Error {
    case noSSID
    case timeout
}

public class ESPTouch: NSObject {
    
    // MARK: - Properties (public)
    
    public var timeout: TimeInterval = 60
    
    // MARK: - Properties (private)
    
    private var locationManager: CLLocationManager?
    private var task: ESPTouchTask?
    private let condition = NSCondition()
    private var isCompletion: Bool = false
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
    }
    
    // MARK: - SmartConfig
    
    private func execute(_ ssid: String, bssid: String, password: String, taskCount: Int, broadcast: Bool) -> [ESPTouchResult] {
        self.condition.lock()
        self.task = ESPTouchTask(apSsid: ssid, andApBssid: bssid, andApPwd: password)
        self.task?.setPackageBroadcast(broadcast)
        self.condition.unlock()
        guard let results = self.task?.execute(forResults: Int32(taskCount)) as? [ESPTouchResult] else {
            return []
        }
        return results
    }
    
    public func currentWiFiSSID() throws -> String?  {
        var currentSSID: String?
        if let ssid = ESPTools.getCurrentWiFiSsid() {
            currentSSID = ssid
            return currentSSID
        } else {
            throw ESPTouchError.noSSID
        }
    }
    
    public func smartConfig(password: String, response: ((Result<ESPTouchResult, ESPTouchError>) -> Void)?) {
        let dispatchQueue = DispatchQueue.global(qos: .default)
        self.isCompletion = false
        dispatchQueue.async {
            guard let ssid = ESPTools.getCurrentWiFiSsid(),
                let bssid = ESPTools.getCurrentBSSID()
            else {
                self.isCompletion = true
                response?(.failure(.noSSID))
                return
            }
            
            // TODO: - Handle multiple results for multiple devices scenario
            let results = self.execute(ssid, bssid: bssid, password: password, taskCount: 1, broadcast: true)
            
            if let result = results.first, (result.bssid ?? "").count > 0 {
                self.isCompletion = true
                response?(.success(result))
            }
        }
        dispatchQueue.asyncAfter(deadline: .now() + timeout) {
            guard !self.isCompletion else {
                print("the task was completed")
                return
            }
            print("task was still in progress when timer elapsed")
            self.cancel()
            response?(.failure(.timeout))
        }
    }
    
    public func cancel() {
        self.condition.lock()
        if let task = self.task {
            task.interrupt()
        }
        self.condition.unlock()
        self.isCompletion = true
    }
    
}
